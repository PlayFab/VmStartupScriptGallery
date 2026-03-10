<#
.SYNOPSIS
  Detects the CPU SKU of an Azure VM and sends it to PlayFab as a telemetry event.
.DESCRIPTION
  VmStartupScript that queries Win32_Processor for CPU model, core count, clock speed,
  and architecture, maps the model to a known microarchitecture, then sends a
  vm_cpu_sku_detected event to PlayFab via the WriteTelemetryEvents API.
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
#>

param(
    [string]$TelemetryKey = ""
)

# Set Error Action to Stop
$ErrorActionPreference = "Stop"

# Grab the script path
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Write-Output "the current script path is $scriptPath"

Write-Output "=== VmStartupScript: CPU SKU Telemetry ==="
Write-Output "Timestamp: $(Get-Date -Format 'o')"

# ── Configuration ──────────────────────────────────────────────────────────────

if (-not $TelemetryKey)
{
    Write-Error "Telemetry key not set. Edit the default value in the param() block at the top of this script."
    exit 1
}

$titleId = $env:PF_TITLE_ID
if (-not $titleId)
{
    Write-Error "PF_TITLE_ID environment variable is not set. This script must run as an MPS VmStartupScript."
    exit 1
}

# ── CPU Detection ──────────────────────────────────────────────────────────────

Write-Output ""
Write-Output "Detecting CPU information..."

$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

$cpuModelName = $cpu.Name.Trim()
$physicalCores = $cpu.NumberOfCores
$logicalProcessors = $cpu.NumberOfLogicalProcessors
$maxClockSpeedMHz = $cpu.MaxClockSpeed
$cpuDescription = $cpu.Description
$cpuArchitecture = switch ($cpu.Architecture)
{
    0 { "x86" }
    5 { "ARM" }
    9 { "x64" }
    12 { "ARM64" }
    default { "Unknown ($($cpu.Architecture))" }
}

Write-Output "  Model:       $cpuModelName"
Write-Output "  Cores:       $physicalCores physical, $logicalProcessors logical"
Write-Output "  Clock:       $maxClockSpeedMHz MHz"
Write-Output "  Arch:        $cpuArchitecture"
Write-Output "  Description: $cpuDescription"

# ── Microarchitecture Mapping ──────────────────────────────────────────────────

function Get-CpuMicroarchitecture([string]$ModelName)
{
    # Intel Xeon processors commonly used in Azure VMs
    # Cascade Lake (2019)
    if ($ModelName -match '8272CL|8280|8260[A-Z]?|6252|4216|4214')
    {
        return "Cascade Lake"
    }
    # Ice Lake (2021)
    if ($ModelName -match '8370C|8380|8368|8358|6338|4314|4310')
    {
        return "Ice Lake"
    }
    # Sapphire Rapids (2023)
    if ($ModelName -match '8473C|8480|8488|8490|6448|4410')
    {
        return "Sapphire Rapids"
    }
    # Emerald Rapids (2024)
    if ($ModelName -match '8592\+|8580|8570|6554|4510')
    {
        return "Emerald Rapids"
    }

    # AMD EPYC processors commonly used in Azure VMs
    # Rome (2nd Gen, 2019)
    if ($ModelName -match 'EPYC\s*7[0-9]{3}(?!\s*V)' -and $ModelName -notmatch 'EPYC\s*7[0-9]{3}V')
    {
        # Rome models: 7452, 7742, etc. (no V suffix)
        if ($ModelName -match '7452|7742|7502|7282|7272|7262|7252|7232')
        {
            return "AMD Rome"
        }
    }
    # Milan (3rd Gen, 2021)
    if ($ModelName -match 'EPYC\s*7.*V3|EPYC\s*7763|EPYC\s*7V13|EPYC\s*7V73')
    {
        return "AMD Milan"
    }
    # Genoa (4th Gen, 2023)
    if ($ModelName -match 'EPYC\s*9[0-9]{3}|EPYC\s*9V33|EPYC\s*9B14')
    {
        return "AMD Genoa"
    }

    # Ampere ARM processors
    if ($ModelName -match 'Ampere|Altra')
    {
        return "Ampere Altra"
    }

    return "Unknown"
}

$microarchitecture = Get-CpuMicroarchitecture $cpuModelName
Write-Output "  Microarch:   $microarchitecture"

# ── Build Telemetry Event ──────────────────────────────────────────────────────

$buildId = $env:PF_BUILD_ID
$vmId = $env:PF_VM_ID
$region = $env:PF_REGION

$eventPayload = @{
    CpuModelName       = $cpuModelName
    Microarchitecture  = $microarchitecture
    PhysicalCores      = $physicalCores
    LogicalProcessors  = $logicalProcessors
    MaxClockSpeedMHz   = $maxClockSpeedMHz
    CpuArchitecture    = $cpuArchitecture
    MpsVmId            = if ($vmId) { $vmId } else { "N/A" }
    BuildId            = if ($buildId) { $buildId } else { "N/A" }
    Region             = if ($region) { $region } else { "N/A" }
}

$requestBody = @{
    Events = @(
        @{
            EventNamespace = "custom.cpu"
            Name           = "vm_cpu_sku_detected"
            Payload        = $eventPayload
        }
    )
} | ConvertTo-Json -Depth 10

Write-Output ""
Write-Output "Sending telemetry event to PlayFab (Title: $titleId)..."

# ── Send to PlayFab WriteTelemetryEvents ───────────────────────────────────────

$uri = "https://$titleId.playfabapi.com/Event/WriteTelemetryEvents"
$headers = @{
    "X-TelemetryKey" = $TelemetryKey
    "Content-Type"   = "application/json"
}

try
{
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $requestBody -TimeoutSec 30
    Write-Output "Telemetry event sent successfully."
    if ($response.data.AssignedEventIds)
    {
        Write-Output "  Event IDs: $($response.data.AssignedEventIds -join ', ')"
    }
}
catch
{
    # Log the error but do NOT fail the startup script — we don't want
    # CPU telemetry failure to prevent game servers from starting.
    Write-Output "WARNING: Failed to send telemetry event to PlayFab."
    Write-Output "  Error: $($_.Exception.Message)"
    if ($_.ErrorDetails.Message)
    {
        Write-Output "  Details: $($_.ErrorDetails.Message)"
    }
}

Write-Output ""
Write-Output "=== VmStartupScript completed ==="
exit 0

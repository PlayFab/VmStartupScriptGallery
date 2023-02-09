<#
.SYNOPSIS
  Configure how much diagnostic data Windows can send.
  https://learn.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization
.DESCRIPTION
  Configure Windows to send Optional Diagnostics Data.
.NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
#>

# Set Error Action to Stop
$ErrorActionPreference = "Stop"

# Grab the script path 
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Write-Output "the current script path is $scriptPath"

# There are 2 paths in the registry where Diagnostic data can be set
# Configure Registry variables to allow optional diagnostic data policies
function SetAndOutputRegistryKey {
  param (
    [string]$RegistryPath,
    [string]$KeyName,
    [int]$KeyValue
  )
  Set-ItemProperty -Path $RegistryPath -Name $KeyName -Value $KeyValue
  Get-ItemProperty -Path $RegistryPath -Name $KeyName
}

Write-Output "Configuring the allowed level in the group policy"
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
SetAndOutputRegistryKey -RegistryPath $registryPath -KeyName "AllowDeviceNameInTelemetry" -KeyValue 1
SetAndOutputRegistryKey -RegistryPath $registryPath -KeyName "AllowTelemetry_PolicyManager" -KeyValue 3

Write-Output "Configuring the Diagnostic level to Optional"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
SetAndOutputRegistryKey -RegistryPath $registryPath -KeyName "AllowTelemetry"  -KeyValue 3
SetAndOutputRegistryKey -RegistryPath $registryPath -KeyName "MaxTelemetryAllowed"  -KeyValue 3
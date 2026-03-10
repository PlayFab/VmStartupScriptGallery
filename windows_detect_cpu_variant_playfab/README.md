# Detect CPU variant and send to PlayFab

## Introduction

This script detects the CPU SKU and microarchitecture of an Azure VM and sends it to [PlayFab](https://learn.microsoft.com/en-us/gaming/playfab/) as a custom telemetry event via the [WriteTelemetryEvents](https://learn.microsoft.com/en-us/rest/api/playfab/events/play-stream-events/write-telemetry-events) API.

## What it does

When an MPS VM starts, this script runs before game servers launch and:

1. Detects CPU info via WMI (`Win32_Processor`) — model name, core count, clock speed, architecture
2. Maps the CPU model to a known microarchitecture (Cascade Lake, Ice Lake, Sapphire Rapids, AMD Milan, etc.)
3. Sends a `vm_cpu_sku_detected` telemetry event to PlayFab using `X-TelemetryKey` auth

The script is **non-blocking** — if the telemetry call fails, it logs a warning and exits 0 so game servers still start normally.

This script is applicable if you are running Windows MPS Builds using Windows containers or processes for your game servers.

## Usage

You will need a **Telemetry Key** — generate one in Game Manager → **Settings** → **Telemetry Keys**. Then edit `PF_StartupScript.ps1` and set your telemetry key in the `$TelemetryKey` default parameter.

You can now create a new MPS Build with your startup script using the [instructions here](https://learn.microsoft.com/en-us/gaming/playfab/features/multiplayer/servers/vmstartupscript).

## Querying Events

In Game Manager → **Data** → **Data Explorer** (Advanced mode):

```kusto
['events.all']
| where FullName_Name == "vm_cpu_sku_detected"
| extend CpuModel = tostring(EventData.CpuModelName),
         Microarch = tostring(EventData.Microarchitecture),
         Cores = toint(EventData.PhysicalCores),
         VmId = tostring(EventData.MpsVmId),
         Region = tostring(EventData.Region)
| project Timestamp, VmId, Region, CpuModel, Microarch, Cores
| order by Timestamp desc
```

# Configure Windows diagnostic data

## Introduction

Windows has a built in diagnostic data collection system that can send extra-telemetry from your MPS Windows based build.

## What it does

The script enables Windows to send optional diagnostic data to Microsoft, notably crash reporting and crash dumps managed by [Windows Error Reporting](https://learn.microsoft.com/en-us/windows/win32/wer/windows-error-reporting). The error reporting feature enables users to notify Microsoft of application faults, kernel faults, unresponsive applications, and other application specific problems. Microsoft can use the error reporting feature to provide customers with troubleshooting information, solutions, or updates for their specific problems.

This script is applicable if you are running Windows MPS Builds using Windows processes for your game servers.

## Usage

You can now create a new MPS Build with your startup script using the [instructions here](https://learn.microsoft.com/en-us/gaming/playfab/features/multiplayer/servers/vmstartupscript).

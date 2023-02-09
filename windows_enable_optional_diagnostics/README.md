# Configure Windows diagnostic data

## Introduction

Windowds has a built in diagnostic data collection system that can send extra-telemtry from your MPS Windows based build

## What it does

The script enables windows to send optional diagnostic data
notably crash reporting and crash dumps managed by [Windows Error Reporting](https://learn.microsoft.com/en-us/windows/win32/wer/windows-error-reporting)

This script is applicable if you are running Windows MPS Builds using Windows processes for your game servers.

## Usage

You can now create a new MPS Build with your startup script using the [instructions here](https://learn.microsoft.com/en-us/gaming/playfab/features/multiplayer/servers/vmstartupscript).
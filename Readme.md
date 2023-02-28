# VmStartupScriptGallery

## Introduction

VmStartupScript is a new feature for Azure PlayFab Multiplayer Servers (MPS) that allows you to customize each Virtual Machine that will host your game servers. Feature is currently in preview, you can see the docs [here](https://learn.microsoft.com/en-us/gaming/playfab/features/multiplayer/servers/vmstartupscript).

This repository aims to include script files and relevant instructions (recipes) about integration of various popular open source utilities and services with MPS. Repository is open to contributions!

A lot of these samples require an [Azure subscription, click here to get started with the free offering](https://azure.com/free).

## Contents

### Linux

| Link | Description |
| ----- | ----------- |
| [Linux New Script Template](linux_new_script_template) | You should use this script to get started with using the feature in Linux VMs. |
| [Linux metrics and/or logs with Telegraf and PlayFab](linux_logs_metrics_telegraf_playfab) | This script installs and configures [Telegraf](https://github.com/influxdata/telegraf) to send VM performance metrics (CPU/memory/disk/network) and/or container logs to [PlayFab](https://learn.microsoft.com/en-us/gaming/playfab/). |
| [Linux metrics with Telegraf and Azure Monitor](linux_metrics_telegraf_azuremonitor) | This script installs and configures [Telegraf](https://github.com/influxdata/telegraf) to send VM performance metrics (CPU/memory/disk/network) to [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/overview). |
| [Linux logs with Telegraf and Azure Data Explorer (Kusto)](linux_logs_telegraf_kusto) | This script installs and configures [Telegraf](https://github.com/influxdata/telegraf) to capture real-time logs from your game servers and send them to [Azure Data Explorer (Kusto)](https://learn.microsoft.com/en-us/azure/data-explorer/data-explorer-overview). |
| [Linux logs with Fluent Bit and Azure Data Explorer (Kusto)](linux_logs_fluentbit_kusto) | This script installs and configures [Fluent Bit](https://github.com/fluent/fluent-bit) to capture real-time logs from your game servers and send them to [Azure Data Explorer (Kusto)](https://learn.microsoft.com/en-us/azure/data-explorer/data-explorer-overview). |
| [Linux logs with Fluent Bit and Azure Blob Storage](linux_logs_fluentbit_azurestorage) | This script installs and configures [Fluent Bit](https://github.com/fluent/fluent-bit) to capture real-time logs from your game servers and send them to [Azure Blob Storage](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction). |

### Windows

| Link | Description |
| ----- | ----------- |
| [Windows New Script Template](windows_new_script_template) | You should use this script to get started with using the feature in Windows VMs. |
| [Windows metrics with Telegraf and Azure Monitor](windows_metrics_telegraf_azuremonitor) | This script installs and configures [Telegraf](https://github.com/influxdata/telegraf) to send VM performance metrics (CPU/memory/disk/network) to [Azure Monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/overview). |
| [Windows enable optional diagnostics](windows_enable_optional_diagnostics) | This script enables sending diagnostic data notify Microsoft of application faults, kernel faults, unresponsive applications, and other application specific problems. |

## Debugging

If you encounter challenges when running the scripts, you can see the [instructions here on how to connect to Windows and Linux machines using RDP or SSH](https://learn.microsoft.com/en-us/gaming/playfab/features/multiplayer/servers/directly-debugging-game-servers). The first thing you should take a look at are the files `PF_StartupScriptStdOut.txt` and `PF_StartupScriptStdErr.txt` that contain the script's standard output and standard error streams. These files are located either on `D:\` drive on Windows or on `/mnt` folder on Linux.

### Linux tips

Some useful commands if you are interacting with systemd services on Linux:

- `systemctl status <service>` - check the status of a service
- `journalctl -u <service>` - check the logs of a service. Press `q` to exit and space bar to see the next log entries.
- `sudo systemctl stop <service>` - stop a service
- `sudo systemctl start <service>` - start a service

## Contributing

Contributions are welcome, we would be more than happy to accept your Pull Requests! Please see the [contributing guide](CONTRIBUTING.md) for more information.

## Support

Support for these scripts is community based via GitHub issues. MPS team does not directly support these scripts which are provided under no warranties of any kind. If you have questions or need help, please open an [issue](https://github.com/PlayFab/VmStartupScriptGallery/issues).

## Links

- [PlayFab Multiplayer Services](https://playfab.com/multiplayer)
- [PlayFab Multiplayer Servers Documentation](https://docs.microsoft.com/en-us/gaming/playfab/features/multiplayer/servers/overview)
- [PlayFab Game Server SDK (GSDK)](https://github.com/PlayFab/gsdk)
- [PlayFab GSDK samples](https://github.com/PlayFab/MpsSamples)
- [Local Multiplayer Agent](https://github.com/PlayFab/MpsAgent)

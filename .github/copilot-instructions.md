# Copilot Instructions for VmStartupScriptGallery

## Project Overview

A gallery of startup scripts for **Azure PlayFab Multiplayer Servers (MPS)** that customize VMs hosting game servers. Each top-level folder is a self-contained recipe integrating tools like Telegraf or Fluent Bit with PlayFab MPS for metrics/logs collection.

## Linting

Shell scripts are validated with **ShellCheck** (severity: `error`) on every PR and push to `main`. There is no PowerShell linting in CI currently.

Run ShellCheck locally:

```bash
shellcheck <script>.sh
```

## Architecture

Each recipe follows this folder structure:

```
{platform}_{category}_{tool}_{backend}/
├── PF_StartupScript.ps1  # Windows entry point (PowerShell)
├── PF_StartupScript.sh   # Linux entry point (Bash)
├── README.md
├── telegraf.conf          # or config.conf for Fluent Bit
└── [other supporting files]
```

- **Entry point is always `PF_StartupScript.ps1` or `PF_StartupScript.sh`** — PlayFab MPS invokes this by name.
- Folder naming convention: `{linux|windows}_{category}_{tool}_{backend}` (e.g., `linux_logs_fluentbit_kusto`). Cross-platform recipes use `windows_linux_` prefix.
- Templates for new recipes are in `windows_new_script_template/` and `linux_new_script_template/`.

## Script Conventions

### Linux (Bash)

- Always start with strict mode:
  ```bash
  set -o errexit
  set -o nounset
  set -o xtrace
  set -o pipefail
  ```
- Export `DIR` for accessing sibling files:
  ```bash
  export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  ```
- Strip Windows line endings from config files before use: `sed -i -e 's/\r$//' <file>`
- Use `systemctl` for service management (stop → configure → restart).
- Must pass ShellCheck.

### Windows (PowerShell)

- Include PSDoc comment block (`.SYNOPSIS`, `.DESCRIPTION`, `.NOTES` with Version/Author/Purpose).
- Set `$ErrorActionPreference = "Stop"` at the top.
- Get script directory via `$MyInvocation.MyCommand.Definition` for accessing sibling assets.
- Install services with the tool's CLI (e.g., `telegraf.exe --service install`).

### Configuration Templating

Config files (telegraf.conf, config.conf) use placeholder tokens that scripts replace at runtime:

- Placeholder format: `_%VARIABLE_NAME%_` (e.g., `_%PF_TITLE_ID%_`)
- Linux uses `sed -e 's/_%PF_TITLE_ID%_/'"$PF_TITLE_ID"'/g'`
- Windows uses `Get-Content` + `-replace` + `Set-Content`

### PlayFab Environment Variables

Available at runtime on MPS VMs — use these in scripts and config templates:

- `PF_TITLE_ID`, `PF_BUILD_ID`, `PF_VM_ID`, `PF_REGION`
- `PF_SHARED_CONTENT_FOLDER_VM` (path to shared content)

Output logs go to `D:\PF_StartupScriptStdOut.txt` / `PF_StartupScriptStdErr.txt` (Windows) or `/mnt/` (Linux).

## Contributing

- CLA signature required: <https://cla.opensource.microsoft.com/microsoft/.github>
- Use the template folders as starting points for new recipes.
- Vendor binaries (`.zip`, `.deb`) are gitignored — include download instructions in your script or README instead.

<#
.SYNOPSIS
  <Overview of script>
.DESCRIPTION
  <Brief description of script>
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
echo "the current script path is $scriptPath"

# these are some of the env variables that are available to you
echo "PlayFab Title ID is $env:PF_TITLE_ID" # e.g. 59F84
echo "PlayFab Build ID is $env:PF_BUILD_ID" # Guid, e.g. 09d91059-22d3-4d0a-8c99-f34f80525aae
echo "PlayFab Virtual Machine ID is $env:PF_VM_ID" # e.g. vmss:SouthCentralUs:2458795A9259968E_12fe54be-fae1-41aa-83d9-09b809d5ef01:09d91059-22d3-4d0a-8c99-f34f80525aae
echo "Region where the VM is deployed is $env:PF_REGION" # e.g. SouthCentralUs

# configure the telegraf configuration file with proper dimensions (title ID/build ID/vm ID)
$telegrafConfPath = "$scriptPath\telegraf.conf"
((Get-Content -path $telegrafConfPath -Raw) -replace '_%PF_TITLE_ID%_', "$env:PF_TITLE_ID") | Set-Content -Path $telegrafConfPath
((Get-Content -path $telegrafConfPath -Raw) -replace '_%PF_BUILD_ID%_', "$env:PF_BUILD_ID") | Set-Content -Path $telegrafConfPath
((Get-Content -path $telegrafConfPath -Raw) -replace '_%PF_VM_ID%_', "$env:PF_VM_ID") | Set-Content -Path $telegrafConfPath

# install telegraf as a Windows service
$telegrafPath = 'C:\Program Files\telegraf'
New-Item -ItemType Directory -Force -Path "$telegrafPath"
cp "$scriptPath\telegraf.*" "$telegrafPath"
cd "$telegrafPath"
.\telegraf.exe --service install --config "$telegrafPath\telegraf.conf"

# start the telegraf service
.\telegraf.exe --service start
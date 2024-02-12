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
echo "Shared content folder is $env:PF_SHARED_CONTENT_FOLDER_VM" # e.g. D:\sharedcontentfolder (All servers running on this VM have access to this folder through the PF_SHARED_CONTENT_FOLDER env variable.)

#!/bin/bash
set -o errexit # script exits when a command fails == set -e
set -o nounset # script exits when tries to use undeclared variables == set -u
set -o xtrace # trace what's executed == set -x (useful for debugging)
set -o pipefail # causes pipelines to retain / set the last non-zero status

# get script's path. This is useful if you want to install any assets that are in the same folder as the script
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "scipt is located in the path: ${DIR}"

echo "sample output from VmStartupScript" > /tmp/foo

# these are some of the env variables that are available to you
echo "PlayFab Title ID is ${PF_TITLE_ID}" # e.g. 59F84
echo "PlayFab Build ID is ${PF_BUILD_ID}" # Guid, e.g. 09d91059-22d3-4d0a-8c99-f34f80525aae
echo "PlayFab Virtual Machine ID is ${PF_VM_ID}" # e.g. vmss:SouthCentralUs:2458795A9259968E_12fe54be-fae1-41aa-83d9-09b809d5ef01:09d91059-22d3-4d0a-8c99-f34f80525aae
echo "Region where the VM is deployed is ${PF_REGION}" # e.g. SouthCentralUs

# rest of your script goes here
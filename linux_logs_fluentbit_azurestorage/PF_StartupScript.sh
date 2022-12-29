#!/bin/bash
set -o errexit # script exits when a command fails == set -e
set -o nounset # script exits when tries to use undeclared variables == set -u
set -o xtrace # trace what's executed == set -x (useful for debugging)
set -o pipefail # causes pipelines to retain / set the last non-zero status

echo "lala" > /tmp/lala

# get script's path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install fluent-bit
# https://docs.fluentbit.io/manual/installation/linux/ubuntu
# it's recommended to download and package it in the .zip file though, for better performance
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh

# stop fluent-bit daemon to apply the new configuration
systemctl stop fluent-bit

# remove \r\n in-place, just in case
sed -i -e 's/\r$//' ${DIR}/config.conf 

# PF_VM_ID is vmss:SouthCentralUs:2458795A9259968E_12fe54be-fae1-41aa-83d9-09b809d5ef01:09d91059-22d3-4d0a-8c99-f34f80525aae
# this cannot be used as the container name in Azure Storage so
# we split it on :
arrIN=(${PF_VM_ID//:/ })
# we create the Blob path with region and the last element of VmID
BLOB_PATH="${PF_REGION,,}-${arrIN[3]}"

# container names on Azure should contain only lowercase letters, numbers and dashes, up to 63 characters
# so we convert titleID/buildID to the specified format
BLOB_CONTAINER="${PF_TITLE_ID,,}-${PF_BUILD_ID,,}"

# replace placeholders in config file
sed -e "s/_%BLOB_CONTAINER%_/${BLOB_CONTAINER}/g" -e "s/_%BLOB_PATH%_/${BLOB_PATH}/g" ${DIR}/config.conf > /etc/fluent-bit/fluent-bit.conf

# restart fluent-bit to apply the new configuration
systemctl restart fluent-bit

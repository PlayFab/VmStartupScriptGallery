#!/bin/bash
set -o errexit # script exits when a command fails == set -e
set -o nounset # script exits when tries to use undeclared variables == set -u
set -o xtrace # trace what's executed == set -x (useful for debugging)
set -o pipefail # causes pipelines to retain / set the last non-zero status

# get script's path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install fluent-bit
# https://docs.fluentbit.io/manual/installation/linux/ubuntu
# it's recommended to download and package it in the .zip file though, for better performance
curl https://raw.githubusercontent.com/fluent/fluent-bit/master/install.sh | sh

# stop fluent-bit daemon to apply the configuration 
systemctl stop fluent-bit

# remove \r\n in-place, just in case
sed -i -e 's/\r$//' ${DIR}/config.conf 

# replace placeholders in config file
sed -e "s/_%PF_TITLE_ID%_/${PF_TITLE_ID}/g" -e "s/_%PF_BUILD_ID%_/${PF_BUILD_ID}/g" -e "s/_%PF_REGION%_/${PF_REGION}/g" -e "s/_%PF_VM_ID%_/${PF_VM_ID}/g" ${DIR}/config.conf > /etc/fluent-bit/fluent-bit.conf

# restart fluent-bit to apply the configuration
systemctl restart fluent-bit

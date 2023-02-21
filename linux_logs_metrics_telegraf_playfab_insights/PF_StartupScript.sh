#!/bin/bash
set -o errexit # script exits when a command fails == set -e
set -o nounset # script exits when tries to use undeclared variables == set -u
set -o xtrace # trace what's executed == set -x (useful for debugging)
set -o pipefail # causes pipelines to retain / set the last non-zero status

# get script's path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install telegraf
sudo apt-get -yq --no-install-recommends install "${DIR}"/telegraf.deb

# mark the output plugin as executable
chmod +x "${DIR}"/telegraftoplayfabinsights

# stop telegraf daemon so we can apply the new config file
systemctl stop telegraf

# remove \r\n in-place
sed -i -e 's/\r$//' ${DIR}/telegraf.conf 
sed -i -e 's/\r$//' ${DIR}/plugin.conf 

mkdir -p /etc/telegraf || echo 'Warning: /etc/telegraf already exists'

# add PF_TITLE_ID, PF_BUILD_ID, PF_VM_ID to telegraf.conf as dimensions
sed -e "s/_%PF_TITLE_ID%_/${PF_TITLE_ID}/g" -e "s/_%PF_BUILD_ID%_/${PF_BUILD_ID}/g" -e "s/_%PF_VM_ID%_/${PF_VM_ID}/g" -e "s/_%PF_REGION%_/${PF_REGION}/g" ${DIR}/telegraf.conf > /etc/telegraf/telegraf.conf

systemctl restart telegraf

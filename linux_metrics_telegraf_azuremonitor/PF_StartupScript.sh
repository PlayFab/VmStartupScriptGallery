#!/bin/bash
set -o errexit # script exits when a command fails == set -e
set -o nounset # script exits when tries to use undeclared variables == set -u
set -o xtrace # trace what's executed == set -x (useful for debugging)
set -o pipefail # causes pipelines to retain / set the last non-zero status

# get script's path
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# install telegraf - change it to the appropriate file name
sudo apt-get -yq --no-install-recommends install "${DIR}"/telegraf.deb

# stopping telegraf so we can write the proper configuration
systemctl stop telegraf

# You should modify the lines below with the output from the az CLI script
# these values are environment variables for the telegraf daemon
# az ad sp create-for-rbac --role="Monitoring Metrics Publisher" --scopes="/subscriptions/<subscriptionID where the metrics will be published>"

echo "AZURE_TENANT_ID=<tenantID>" >> /etc/default/telegraf
echo "AZURE_CLIENT_ID=<clientID>" >> /etc/default/telegraf
echo "AZURE_CLIENT_SECRET=<clientSecret>" >> /etc/default/telegraf

# remove \r\n in-place, just in case
sed -i -e 's/\r$//' ${DIR}/telegraf.conf 

mkdir -p /etc/telegraf || echo 'Warning: /etc/telegraf already exists'

# add PF_TITLE_ID, PF_BUILD_ID, PF_VM_ID, PF_REGION to telegraf.conf as dimensions
sed -e "s/_%PF_TITLE_ID%_/${PF_TITLE_ID}/g" -e "s/_%PF_BUILD_ID%_/${PF_BUILD_ID}/g" -e "s/_%PF_VM_ID%_/${PF_VM_ID}/g" -e "s/_%PF_REGION%_/${PF_REGION}/g" ${DIR}/telegraf.conf > /etc/telegraf/telegraf.conf

# restart telegraf to apply the new configuration
systemctl restart telegraf

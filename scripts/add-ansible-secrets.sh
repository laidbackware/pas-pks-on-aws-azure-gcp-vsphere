#!/bin/bash
# Add VM extensions

set -euxo pipefail

pushd yq
chmod +x yq*
cp yq* /usr/local/bin/yq
popd

yq w -i ${ROOT_DIR}/config/${VSPHERE_ANSWERS} nested_host_credentials.password ${NESTED_HOST_PASSWORD}
yq w -i ${ROOT_DIR}/config/${VSPHERE_ANSWERS} parent_vcenter.user ${PARENT_VCENTER_USERNAME}
yq w -i ${ROOT_DIR}/config/${VSPHERE_ANSWERS} parent_vcenter.password ${PARENT_VCENTER_PASSWORD}
yq w -i ${ROOT_DIR}/config/${VSPHERE_ANSWERS} nested_vcenter.password ${NESTED_VCENTER_PASSWORD}
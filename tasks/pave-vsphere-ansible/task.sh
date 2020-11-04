#!/bin/bash

set -euxo pipefail

export ROOT_DIR="$(pwd)"

mkdir -v tmp
VC_ISO="$(ls -d ${ROOT_DIR}/vcenter-iso/*.iso)"
ESXI_OVA="$(ls -d ${ROOT_DIR}/esxi-ova/*.ova)"

echo "Using ISO ${VC_ISO}"
ansible-playbook "${ROOT_DIR}/vsphere-ansible-repo/deploy.yml" \
    --extra-vars="@${ROOT_DIR}/config/${VSPHERE_ANSWERS}" \
    --extra-vars "tmp_dir=${ROOT_DIR}/tmp vc_iso=${VC_ISO} esxi_ova=${ESXI_OVA} \
    environment_tag=${FOUNDATION}"
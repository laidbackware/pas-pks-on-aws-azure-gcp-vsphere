#!/bin/bash

set -euxo pipefail

export ROOT_DIR="$(pwd)"

mkdir -v tmp
VC_ISO="$(ls -d ${ROOT_DIR}/vcenter-iso/*.iso)"

echo "Using ISO ${VC_ISO}"
ansible-playbook "${ROOT_DIR}/vsphere-ansible-repo/deploy.yml" \
    --extra-vars="@${ROOT_DIR}/config/${VSPHERE_ANSWERS}" \
    --extra-vars "tmp_dir=${ROOT_DIR}/tmp vcIso=${VC_ISO} \
    environment_tag=${FOUNDATION}"
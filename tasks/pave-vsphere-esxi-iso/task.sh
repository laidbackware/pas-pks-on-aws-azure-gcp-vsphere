#!/bin/bash

set -euxo pipefail

export ROOT_DIR="$(pwd)"

TMPDIR=$(mktemp -d) || exit 1
echo "Temp dir is ${TMPDIR}"

ESXI_ISO="$(ls -d ${ROOT_DIR}/esxi-iso/*.iso)"

echo "Using ISO ${ESXI_ISO}"

ansible-playbook "${ROOT_DIR}/vsphere-ansible-repo/playbooks/prepare_esxi_iso_installer.yml" \
    --extra-vars="@${ROOT_DIR}/config/${VSPHERE_ANSWERS}" --extra-vars "tmp_dir=${TMPDIR} esxIso=${ESXI_ISO}"
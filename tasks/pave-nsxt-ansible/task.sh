#!/bin/bash

set -euxo pipefail

shopt -s expand_aliases
if type python3 > /dev/null; then
  alias python="$(which -a python3 | head -n 1)"
  echo "Aliasing python3 to python"
fi
python --version

# Reduce default sleep between commands
sed -i 's/time.sleep(5)/time.sleep(1)/g' ./nsxt-ansible/library/* 

ROOT_DIR="$(pwd)"
NSXT_OVA_FILE="$(cd ${ROOT_DIR}/nsxt-ova/; ls *.ova)"
NSXT_OVA_PATH="${ROOT_DIR}/nsxt-ova/"

export ANSIBLE_LIBRARY="${PWD}/nsxt-ansible"
export ANSIBLE_MODULE_UTILS="${PWD}/nsxt-ansible/module_utils"

mkdir -p ${ROOT_DIR}/certs
CERT_DIR=${ROOT_DIR}/certs
NSX_VARS=${ROOT_DIR}/config/vars/${FOUNDATION}/nsxt-answerfile.yml
VSPHERE_VARS=${ROOT_DIR}/config/vars/${FOUNDATION}/vsphere-answerfile.yml
# VARS=${ROOT_DIR}/config/vars/${FOUNDATION}/common-vars.yml

# ansible-for-nsxt expects certificate files
echo "${NSX_API_PUBLIC_KEY}" > ${CERT_DIR}/nsx.crt
echo "${NSX_API_PRIVATE_KEY}" > ${CERT_DIR}/nsx.key
echo "${PKS_USER_USER_PUBLIC_KEY}" > ${CERT_DIR}/pks-super-user.crt
echo "${PKS_USER_USER_PRIVATE_KEY}" > ${CERT_DIR}/pks-super-user.key

echo "Using NSXT_OVA ${NSXT_OVA_PATH}/${NSXT_OVA_FILE}"
ansible-playbook "${ROOT_DIR}/config/playbooks/nsxt_deploy_base.yml" \
    --extra-vars="@${NSX_VARS}" \
    --extra-vars="@${VSPHERE_VARS}"\
    --extra-vars "manager_ova_file=${NSXT_OVA_FILE} manager_path_to_ova=${NSXT_OVA_PATH} \
    cert_path=${CERT_DIR} environment_tag=${FOUNDATION}" -vvv

ansible-playbook "${ROOT_DIR}/config/playbooks/nsxt_deploy_tier_0.yml" \
    --extra-vars="@${NSX_VARS}" -vvv

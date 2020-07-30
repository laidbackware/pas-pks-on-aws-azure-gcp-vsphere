#!/bin/bash
# Script to remove nested VMs and update S3 objects

set -euxo pipefail

if [ ! ${IAAS_TYPE} = "vsphere" ]; then
    echo "Not needed for vsphere"
    exit 0
fi

ROOT_DIR="$(pwd)"

VSPHERE_VARS=${ROOT_DIR}/config/vars/${FOUNDATION}/vsphere-answerfile.yml

export GOVC_USERNAME=$(bosh int <(echo ${CLOUD_CREDS}) --path /parent_vcenter_username)
export GOVC_PASSWORD=$(bosh int <(echo ${CLOUD_CREDS}) --path /parent_vcenter_password)
export GOVC_DATACENTER=$(bosh int ${VSPHERE_VARS} --path /parent_vcenter/datacenter) \
    || exit $? && export GOVC_DATACENTER
export GOVC_URL=https://$(bosh int ${VSPHERE_VARS} --path /parent_vcenter/ip) \
    || exit $? && export GOVC_URL
export GOVC_INSECURE=true

NSX_VM_NAME=${FOUNDATION}-nsxt-manager
ESXI_VM_NAME=${FOUNDATION}-esx1
VCENTER_VM_NAME=${FOUNDATION}-vcenter

VMS="$(govc ls /${GOVC_DATACENTER}/vm)"

TO_DELETE=""

for vm in ${VMS}
do
    if [[ $vm == *"${FOUNDATION}-"* ]]; then
        echo "VM ${vm} markded for deletion"
        TO_DELETE="${TO_DELETE} ${vm}"
    fi
done

echo "$TO_DELETE"

if [ ! -z "$TO_DELETE" ]
then
    govc vm.power -off=true -wait=true -force=true $TO_DELETE
    govc vm.destroy $TO_DELETE
fi

pushd s5cmd
tar xvfz s5cmd_*_Linux-64bit.tar.gz
mv s5cmd /usr/local/bin
popd

OM_STATE_FILE="${ROOT_DIR}/om-state-$(date '+%Y%m%d.%-H%M.%S+%Z').yml"
echo "iaas: vsphere" >> ${OM_STATE_FILE}
echo "" >> ${ROOT_DIR}/terraform.tfstate


s5cmd --endpoint-url  ${S3_ENDPOINT} --no-verify-ssl \
    cp ${OM_STATE_FILE} s3://opsman-state/${FOUNDATION}/
s5cmd --endpoint-url  ${S3_ENDPOINT} --no-verify-ssl \
    rm s3://terraform-state/${FOUNDATION}/terraform.tfstate

# TODO 
# add support for more than 1 ESXi host
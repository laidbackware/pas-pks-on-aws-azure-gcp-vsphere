#!/bin/bash

set -euxo pipefail

ROOT_DIR="$(pwd)"

# Setup tools
cp ${ROOT_DIR}/terraform/terraform-* /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform

if [ ${IAAS_TYPE} = "vsphere" ]; then
    NSX_VAR_FILE=${ROOT_DIR}/config/vars/${FOUNDATION}/nsxt-answerfile.yml
    if [ ! -f $NSX_VAR_FILE ]; then 
        echo "${NSX_VAR_FILE} File not found!"
        exit 1
    fi
    export TF_VAR_nsxt_host="$(bosh int ${NSX_VAR_FILE} --path /nsx_manager/hostname)"
    export TF_VAR_nsxt_username="$(bosh int <(echo ${CLOUD_CREDS}) --path /nsx_username)"
    export TF_VAR_nsxt_password="$(bosh int <(echo ${CLOUD_CREDS}) --path /nsx_password)"
    export TF_VAR_overlay_transport_zone_name="$(bosh int ${NSX_VAR_FILE} --path /transportzones/0/display_name)"
    export TF_VAR_vlan_transport_zone_name="$(bosh int ${NSX_VAR_FILE} --path /transportzones/1/display_name)"
    export TF_VAR_nsxt_edge_cluster_name="$(bosh int ${NSX_VAR_FILE} --path /edge_cluster_name)"
    cd ${ROOT_DIR}/config/terraform/nsxt
else # Setup for all cloud providers
    cd ${ROOT_DIR}/config/terraform/${FOUNDATION}
    export TF_VAR_access_key="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_id)"
    export TF_VAR_secret_key="$(bosh int <(echo ${CLOUD_CREDS}) --path  /client_secret)"
fi

if [ ${FOUNDATION} = "azure" ]; then
    export TF_VAR_subscription_id="$(bosh int <(echo ${CLOUD_CREDS}) --path /subscription_id)"
    export TF_VAR_tenant_id="$(bosh int <(echo ${CLOUD_CREDS}) --path /tenant_id)"
fi

terraform init -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="key=${FOUNDATION}/terraform.tfstate" \
    -backend-config="endpoint=${S3_ENDPOINT}"\
    -backend-config="access_key=${STATE_BUCKET_KEY_ID}"\
    -backend-config="secret_key=${STATE_BUCKET_SECRET_KEY}"

terraform plan -out=./tf.plan -var-file=${ROOT_DIR}/config/vars/${FOUNDATION}/terraform.tfvars -input=false

terraform apply -auto-approve ./tf.plan

mkdir -p ${ROOT_DIR}/generated-tf-output/
FILE_VERSION="$(date '+%Y%m%d.%H%M%S')"
OUTPUT_FILE=${ROOT_DIR}/generated-tf-output/tf-output-${FILE_VERSION}.yml

terraform output stable_config_yaml > ${OUTPUT_FILE}
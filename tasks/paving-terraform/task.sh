#!/bin/bash

set -euxo pipefail

ROOT_DIR="$(pwd)"

# Setup tools
cp ${ROOT_DIR}/terraform/terraform-* /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform 
${ROOT_DIR}/config/lib/add-tools/setup-oq.sh

if [ ${FOUNDATION} = "vsphere"* ]; then
    NSX_VAR_FILE=${ROOT_DIR}/config/vars/${FOUNDATION}/nsxt-answerfile.yml
    if [ ! -f $NSX_VAR_FILE ]; then echo "${NSX_VAR_FILE} File not found!"; fi
    export TF_VAR_nsxt_host="$(bosh int $NSX_VAR_FILE  --path /nsx_manager/hostname)"
    export TF_VAR_nsxt_username="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_id)"
    export TF_VAR_nsxt_password="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_secret)"
    export TF_VAR_overlay_transport_zone_name="$(bosh int ${NSX_VAR_FILE} --path /transportzones/0/display_name)"
    export TF_VAR_nsxt_edge_cluster_name="$(bosh int ${NSX_VAR_FILE} --path /edge_cluster_name)"
    export TF_VAR_nsxt_t0_router_name="$(bosh int ${NSX_VAR_FILE} --path /logical_routers/0/router_display_name)"
    # export TF_VAR_nsxt_host="$(oq -i yaml .nsx_manager.hostname $NSX_VAR_FILE | tr -d '"')"
    # export TF_VAR_nsxt_username="$(echo ${CLOUD_CREDS} | oq .client_id | tr -d '"' )"
    # export TF_VAR_nsxt_password="$(echo ${CLOUD_CREDS} | oq .client_secret | tr -d '"' )"
    # export TF_VAR_overlay_transport_zone_name="$(oq -i yaml .transportzones[0].display_name $NSX_VAR_FILE | tr -d '"')"
    # export TF_VAR_nsxt_edge_cluster_name="$(oq -i yaml .edge_cluster_name $NSX_VAR_FILE | tr -d '"')"
    # export TF_VAR_nsxt_t0_router_name="$(oq -i yaml .logical_routers[0].router_display_name $NSX_VAR_FILE | tr -d '"')"
    cd ${ROOT_DIR}/config/terraform/nsxt
else # Setup for all cloud providers
    cd ${ROOT_DIR}/paving-repo/${FOUNDATION}
    cp ${ROOT_DIR}/config/terraform/backend.tf .
    EXTRA_TF_OUTPUTS='
    output "stable_config_yaml" {
        value     = yamlencode(local.stable_config)
        sensitive = true
    }'
    echo "${EXTRA_TF_OUTPUTS}" >> outputs.tf
    export TF_VAR_access_key="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_id)"
    export TF_VAR_secret_key="$(bosh int <(echo ${CLOUD_CREDS}) --path  /client_secret)"
    # export TF_VAR_access_key="$(echo ${CLOUD_CREDS} | oq .client_id | tr -d '"' )"
    # export TF_VAR_secret_key="$(echo ${CLOUD_CREDS} | oq .client_secret | tr -d '"' )"
fi

if [ ${FOUNDATION} = "azure" ]; then
    export TF_VAR_subscription_id="$(bosh int <(echo ${CLOUD_CREDS}) --path /subscription_id)"
    export TF_VAR_tenant_id="$(bosh int <(echo ${CLOUD_CREDS}) --path /tenant_id)"
    # export TF_VAR_subscription_id="$(echo ${CLOUD_CREDS} | oq .subscription_id | tr -d '"' )"
    # export TF_VAR_tenant_id="$(echo ${CLOUD_CREDS} | oq .tenant_id | tr -d '"' )"
fi

terraform init -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="key=${FOUNDATION}/terraform.tfstate" \
    -backend-config="endpoint=${S3_ENDPOINT}"\
    -backend-config="access_key=${STATE_BUCKET_KEY_ID}"\
    -backend-config="secret_key=${STATE_BUCKET_SECRET_KEY}"

terraform plan -out=./tf.plan -var-file=${ROOT_DIR}/config/vars/${FOUNDATION}/terraform.tfvars

terraform apply -auto-approve ./tf.plan

mkdir -p ${ROOT_DIR}/generated-tf-output/
FILE_VERSION="$(date '+%Y%m%d.%H%M%S')"
OUTPUT_FILE=${ROOT_DIR}/generated-tf-output/tf-output-${FILE_VERSION}.yml

terraform output  stable_config_yaml > ${OUTPUT_FILE}
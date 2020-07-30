#!/bin/bash
# Script to setup route 53 for cloud providers

set -euxo pipefail

if [ ${IAAS_TYPE} = "vsphere" ]; then
    echo "Not needed for vsphere"
    exit 0
fi

if [ ${IAAS_TYPE} = "aws" ]; then
    echo "Not needed for AWS"
    exit 0
fi

ROOT_DIR="$(pwd)"

# Setup tools
cp ${ROOT_DIR}/terraform/terraform-* /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform 
# ${ROOT_DIR}/config/lib/add-tools/setup-oq.sh

cd ${ROOT_DIR}/config/terraform/aws-dns
cp ${ROOT_DIR}/config/terraform/backend.tf .

terraform init -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="key=${FOUNDATION}/terraform.tfstate" \
    -backend-config="endpoint=${S3_ENDPOINT}"\
    -backend-config="access_key=${STATE_BUCKET_KEY_ID}"\
    -backend-config="secret_key=${STATE_BUCKET_SECRET_KEY}"

# Azure setup
if [ ${FOUNDATION} = "azure" ]; then
    export TF_VAR_name_servers="$(bosh int ${ROOT_DIR}/generated-tf-output/tf-output*.yml --path /env_dns_zone_name_servers/value)"
    export TF_VAR_forwarding_domain="$(bosh int ${ROOT_DIR}/generated-tf-output/tf-output*.yml --path /ops_manager_dns/value |sed -En s/pcf.//p)" # needs adjusting
fi

terraform plan -out=./tf.plan -var-file ${ROOT_DIR}/config/vars/aws-route-53-terraform.tfvars

terraform apply -auto-approve ./tf.plan

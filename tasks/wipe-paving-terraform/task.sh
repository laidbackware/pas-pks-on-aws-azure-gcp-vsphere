#!/bin/bash

set -euxo pipefail

if [ ${IAAS_TYPE} = "vsphere" ]; then
    echo "Not needed for vsphere"
    exit 0
fi

ROOT_DIR="$(pwd)"

# Setup tools
cp ${ROOT_DIR}/terraform/terraform-* /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform
# ${ROOT_DIR}/config/lib/add-tools/setup-oq.sh

ENV_FILE=vars/${FOUNDATION}/env/env.yml
OM_TARGET=$(bosh int config/${ENV_FILE} --path /target | sed s"/((domain))/${DOMAIN}/")

if $(curl -k --output /dev/null --silent --head --fail -m 5 ${OM_TARGET})
then
    echo "Aborting, Ops Man is still online"
    exit 1
fi

cd ${ROOT_DIR}/paving-repo/${FOUNDATION}
cp ${ROOT_DIR}/config/terraform/backend.tf .
# echo "${EXTRA_TF_OUTPUTS}" >> outputs.tf
export TF_VAR_access_key="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_id)"
export TF_VAR_secret_key="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_secret)"

# export TF_VAR_access_key="$(echo ${CLOUD_CREDS} | oq .client_id | tr -d '"' )"
# export TF_VAR_secret_key="$(echo ${CLOUD_CREDS} | oq .client_secret | tr -d '"' )"


if [ ${FOUNDATION} = "azure" ]; then
    export TF_VAR_subscription_id="$(bosh int <(echo ${CLOUD_CREDS}) --path /subscription_id)"
    export TF_VAR_tenant_id="$(bosh int <(echo ${CLOUD_CREDS}) --path /tenant_id)"
    # export TF_VAR_subscription_id="$(echo ${CLOUD_CREDS} | oq .subscription_id | tr -d '"' )"
    # export TF_VAR_tenant_id="$(echo ${CLOUD_CREDS} | oq .tenant_id | tr -d '"' )"
fi

terraform init -backend-config="bucket=${STATE_BUCKET}" \
    -backend-config="key=${FOUNDATION}/terraform.tfstate" \
    -backend-config="endpoint=${S3_ENDPOINT}"\
    -backend-config="access_key=${STATE_BUCKET_KEY_ID}"\
    -backend-config="secret_key=${STATE_BUCKET_SECRET_KEY}"

terraform destroy -auto-approve -var-file=${ROOT_DIR}/config/vars/${FOUNDATION}/terraform.tfvars

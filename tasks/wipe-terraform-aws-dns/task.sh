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

${ROOT_DIR}/config/lib/add-tools/setup-oq.sh

ENV_FILE=vars/${FOUNDATION}/env/env.yml
OM_TARGET=$(bosh int config/${ENV_FILE} --path /target | sed s"/((domain))/${DOMAIN}/")

if $(curl -k --output /dev/null --silent --head --fail -m 5 ${OM_TARGET})
then
    echo "Aborting, Ops Man is still online"
    exit 1
fi

# Setup tools
cp ${ROOT_DIR}/terraform/terraform-* /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform
# ${ROOT_DIR}/config/lib/add-tools/setup-oq.sh

cd ${ROOT_DIR}/config/terraform/aws-dns
cp ${ROOT_DIR}/config/terraform/backend.tf .

terraform init -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="key=${FOUNDATION}/aws-route-53-terraform.tfstate" \
    -backend-config="endpoint=${S3_ENDPOINT}"\
    -backend-config="access_key=${STATE_BUCKET_KEY_ID}"\
    -backend-config="secret_key=${STATE_BUCKET_SECRET_KEY}"

exit 1
terraform destroy -auto-approve

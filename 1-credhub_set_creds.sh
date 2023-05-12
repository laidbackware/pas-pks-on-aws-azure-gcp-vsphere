#!/bin/bash
# Script to set credhub secrets for pipelines.
# Certs must be generated and placed 1 level higher in the file system structure.
# Opmans public private pair, PKS API, PKS super user and Git private key.
# Remaining secrets will be pulled from lastpass.
# Secrets will print to the screen when run.

set -euxo pipefail

if [[ "$(bw status)" == *"unlocked"* ]]; then
  echo -e "Bitwarden unlocked via BW_SESSION env var"
elif [[ "$(bw status)" == *"unauthenticated"* ]]; then
  export BW_SESSION="$(bw login --raw)"
else
  export BW_SESSION="$(bw unlock --raw)"
fi

source ../ducc/1-vars.inc.sh
# trap 'rm -rf "$TMPDIR"' EXIT

ATTEMPT_COUNTER=0
MAX_ATTEMPTS=12

until $(curl -k --output /dev/null --silent --head --fail https://${DUCC_HOSTNAME}:9000/info); do
    if [ ${ATTEMPT_COUNTER} -eq ${MAX_ATTEMPTS} ];then
      echo "Max attempts reached"
      exit 1
    fi
    ATTEMPT_COUNTER=$(expr ${ATTEMPT_COUNTER} + 1)
    CURRENT_TRY=$(expr ${MAX_ATTEMPTS} - ${ATTEMPT_COUNTER})
    echo "https://${DUCC_HOSTNAME}:9000/info not online yet, ${CURRENT_TRY} more retries left"
    sleep 5
done

credhub login --client-name credhub_client --client-secret ${DUCC_CREDHUB_CLIENT_SECRET} -s https://${DUCC_HOSTNAME}:9000 --skip-tls-validation

# S3_ACCESS_KEY="$(bw get password s3_secret_access_key)"
PIVNET_TOKEN="$(bw get password pivnet_token)"
# AWS_ACCESS_KEY="$(bw get username aws-paving-user)"
# AWS_SECRET_KEY="$(bw get password aws-paving-user)"
GIT_PRIVATE_KEY="$(bw get notes it_private_key)"
OM_PASSWORD="$(bw get password opsman)"
PKS_CLUSTER_ADMIN_USERNAME="$(bw get username pks_cluster_admin_user)"
PKS_CLUSTER_ADMIN_PASSWORD="$(bw get password pks_cluster_admin_user)"
VCENTER_USERNAME="$(bw get username lab_vcenter_creds)"
VCENTER_PASSWORD="$(bw get password lab_vcenter_creds)"
NSXT_LICENSE_KEY="$(bw get notes nsxt_license_key)"

# AWS_JSON="{\"client_id\": \"${AWS_ACCESS_KEY}\", \"client_secret\": \"${AWS_SECRET_KEY}\"}"

# Main section
# VMWARE_DOWNLOAD_USER="$(bw get username vmware-download)"
# VMWARE_DOWNLOAD_PASSWORD="$(bw get password vmware-download)"
credhub set -n /concourse/main/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
credhub set -n /concourse/main/pivnet_token -t password -w "$PIVNET_TOKEN"
credhub set -n /concourse/main/s3_secret_access_key -t password -w minio123
# credhub set -n /concourse/main/vmware_download -t user -z "$VMWARE_DOWNLOAD_USER" -w "$VMWARE_DOWNLOAD_PASSWORD"

# # AWS section
# FOUNDATION=aws
# DOMAIN="$(bw get notes aws_domain)"
# PKS_API_PUBLIC_KEY=$(lpass show aws-pks-api --field=public_key)
# PKS_API_PRIVATE_KEY=$(lpass show aws-pks-api --field=private_key)
# GOROUTER_CA="$(lpass show aws-pas-gorouter --field=ca)"
# GOROUTER_PUBLIC_KEY="$(lpass show aws-pas-gorouter --field=public_key)"
# GOROUTER_PRIVATE_KEY="$(lpass show aws-pas-gorouter --field=private_key)"

# CLOUD_CREDS_JSON="{\"client_id\": \"${AWS_ACCESS_KEY}\", \"client_secret\": \"${AWS_SECRET_KEY}\"}"
# credhub set -n /concourse/${FOUNDATION}/decryption_passphrase -t password -w "${OM_PASSWORD}${OM_PASSWORD}"
# credhub set -n /concourse/${FOUNDATION}/pivnet_token -t password -w "$PIVNET_TOKEN"
# credhub set -n /concourse/${FOUNDATION}/s3_secret_access_key -t password -w minio123
# credhub set -n /concourse/${FOUNDATION}/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
# credhub set -n /concourse/${FOUNDATION}/om_login -t user -z admin -w "$OM_PASSWORD"
# credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "$AWS_ACCESS_KEY" -w "$AWS_SECRET_KEY"
# credhub set -n /concourse/${FOUNDATION}/cloud_creds -t json -v "${CLOUD_CREDS_JSON}"
# credhub set -n /concourse/${FOUNDATION}/domain -t value -v "${DOMAIN}"
# credhub set -n /concourse/${FOUNDATION}/pas_cert -t rsa  -p "${GOROUTER_PRIVATE_KEY}" -u "${GOROUTER_PUBLIC_KEY}"  -m "${GOROUTER_CA}"
# #PKS Secrets
# credhub set -n /concourse/${FOUNDATION}/pks-api -t rsa -p "${PKS_API_PRIVATE_KEY}" -u "${PKS_API_PUBLIC_KEY}"
# credhub set -n /concourse/${FOUNDATION}/pks_cluster_admin_user -t user -z "$PKS_CLUSTER_ADMIN_USERNAME" -w "$PKS_CLUSTER_ADMIN_PASSWORD"

# # Azure section
# FOUNDATION=azure
# DOMAIN="${FOUNDATION}.$(bw get notes aws_domain)"
# AZURE_APP_ID="$(bw get username azure-principal)"
# AZURE_SECRET="$(bw get password azure-principal)"
# AZURE_TENANT_ID="$(bw get notes azure-principal |grep tenant_id: | cut -d " " -f2)"
# AZURE_SUBSCRIPTION_ID="$(bw get notes azure-principal |grep subscription_id: | cut -d " " -f2)"
# CLOUD_CREDS_JSON="{\"client_id\": \"${AZURE_APP_ID}\", \"client_secret\": \"${AZURE_SECRET}\",
#                                             \"azure_tenant_id\": \"${AZURE_TENANT_ID}\", 
#                                             \"azure_subscription_id\": \"${AZURE_SUBSCRIPTION_ID}\"}" #TODO tenant sub
# credhub set -n /concourse/${FOUNDATION}/decryption_passphrase -t password -w "${OM_PASSWORD}${OM_PASSWORD}"
# credhub set -n /concourse/${FOUNDATION}/pivnet_token -t password -w "$PIVNET_TOKEN"
# credhub set -n /concourse/${FOUNDATION}/s3_secret_access_key -t password -w minio123
# credhub set -n /concourse/${FOUNDATION}/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
# credhub set -n /concourse/${FOUNDATION}/om_login -t user -z admin -w "$OM_PASSWORD"
# credhub set -n /concourse/${FOUNDATION}/cloud_creds -t json -v "${CLOUD_CREDS_JSON}"
# # credhub set -n /concourse/${FOUNDATION}/azure_tenant_id -t value -v "${AZURE_TENANT_ID}"
# # credhub set -n /concourse/${FOUNDATION}/azure_subscription_id -t value -v "${AZURE_SUBSCRIPTION_ID}"
# credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "$AWS_ACCESS_KEY" -w "$AWS_SECRET_KEY"
# credhub set -n /concourse/${FOUNDATION}/domain -t value -v "${DOMAIN}"
# # PKS Secrets
# credhub set -n /concourse/${FOUNDATION}/pks_cluster_admin_user -t user -z "$PKS_CLUSTER_ADMIN_USERNAME" -w "$PKS_CLUSTER_ADMIN_PASSWORD"

# # GCP Section
# FOUNDATION=gcp
# GCP_CLIENT_ID=$(bw get notes gcp-service-account |jq .client_id)
# GCP_PRODUCT_ID=$(bw get notes gcp-service-account |jq .project_id)
# GCP_PRIVATE_KEY_ID=$(bw get notes gcp-service-account |jq .private_key_id)
# GCP_PRIVATE_KEY=$(bw get notes gcp-service-account |jq .private_key)
# CLOUD_CREDS_JSON="{\"client_id\": \"${GCP_CLIENT_ID}\", \"client_secret\": \"${GCP_PRIVATE_KEY}\",
#                                             \"gcp_project_id\": \"${GCP_PRODUCT_ID}\", 
#                                             \"gcp_private_key_id\": \"${GCP_PRIVATE_KEY_ID}\"}" #TODO tenant sub
# credhub set -n /concourse/${FOUNDATION}/decryption_passphrase -t password -w "${OM_PASSWORD}${OM_PASSWORD}"
# credhub set -n /concourse/${FOUNDATION}/pivnet_token -t password -w "$PIVNET_TOKEN"
# credhub set -n /concourse/${FOUNDATION}/s3_secret_access_key -t password -w minio123
# credhub set -n /concourse/${FOUNDATION}/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
# credhub set -n /concourse/${FOUNDATION}/om_login -t user -z admin -w "$OM_PASSWORD"
# credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "$AWS_ACCESS_KEY" -w "$AWS_SECRET_KEY"
# credhub set -n /concourse/${FOUNDATION}/cloud_creds -t json -v "${CLOUD_CREDS_JSON}"
# credhub set -n /concourse/${FOUNDATION}/domain -t value -v "${DOMAIN}"
# credhub set -n /concourse/${FOUNDATION}/pas_cert -t rsa  -p "${GOROUTER_PRIVATE_KEY}" -u "${GOROUTER_PUBLIC_KEY}"  -m "${GOROUTER_CA}"
# #PKS Secrets
# credhub set -n /concourse/${FOUNDATION}/pks-api -t rsa -p "${PKS_API_PRIVATE_KEY}" -u "${PKS_API_PUBLIC_KEY}"
# credhub set -n /concourse/${FOUNDATION}/pks_cluster_admin_user -t user -z "$PKS_CLUSTER_ADMIN_USERNAME" -w "$PKS_CLUSTER_ADMIN_PASSWORD"



# vSphere section
FOUNDATION=vsphere
CLOUD_CREDS_JSON="{\"client_id\": \"admin\", \"client_secret\": \"VMware1!VMware1!\",
                                             \"parent_vcenter_username\": \"$VCENTER_USERNAME\",
                                             \"parent_vcenter_password\": \"$VCENTER_PASSWORD\",
                                             \"nsx_username\": \"admin\",
                                             \"nsx_password\": \"VMware1!VMware1!\"}" # client secret used for NSX API auth
credhub set -n /concourse/${FOUNDATION}/decryption_passphrase -t password -w "${OM_PASSWORD}${OM_PASSWORD}"
credhub set -n /concourse/${FOUNDATION}/pivnet_token -t password -w "$PIVNET_TOKEN"
credhub set -n /concourse/${FOUNDATION}/s3_secret_access_key -t password -w minio123
credhub set -n /concourse/${FOUNDATION}/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
credhub set -n /concourse/${FOUNDATION}/om_login -t user -z admin -w "$OM_PASSWORD"
credhub set -n /concourse/${FOUNDATION}/opsman_ssh -t ssh -p ~/.ssh/home -u ~/.ssh/home.pub #TODO
# Infra Secrets
credhub set -n /concourse/${FOUNDATION}/parent_vcenter_credentials -t user -z "$VCENTER_USERNAME" -w "$VCENTER_PASSWORD"
# credhub set -n /concourse/${FOUNDATION}/nsx_password -t password -w "VMware1!VMware1!"
credhub set -n /concourse/${FOUNDATION}/nsx_machine_cert -t rsa -p ../nsx.key -u ../nsx.crt #TODO
credhub set -n /concourse/${FOUNDATION}/nsxt_license_key -t value -v "${NSXT_LICENSE_KEY}"
credhub set -n /concourse/${FOUNDATION}/cloud_creds -t json -v "${CLOUD_CREDS_JSON}"
credhub set -n /concourse/${FOUNDATION}/nested_vcenter_credentials -t user -z administrator@vsphere.local -w "VMware1!"
credhub set -n /concourse/${FOUNDATION}/nested_host_password -t password -w "VMware1!"
# credhub set -n /concourse/${FOUNDATION}/vcenter_password -t password -w "VMware1!"
# PKS Secrets
credhub set -n /concourse/${FOUNDATION}/pks_api_cert -t rsa -p ../../secrets/tkgi/tkgi.home.local-key.pem -u ../../secrets/tkgi/tkgi.home.local.pem
credhub set -n /concourse/${FOUNDATION}/pks_nsx_super_user -t rsa -p ../../secrets/tkgi/pks-nsx-t-superuser.key -u ../../secrets/tkgi/pks-nsx-t-superuser.crt #TODO
credhub set -n /concourse/${FOUNDATION}/pks_cluster_admin_user -t user -z "$PKS_CLUSTER_ADMIN_USERNAME" -w "$PKS_CLUSTER_ADMIN_PASSWORD"
# Below are to allow a single task to pave all IaaS and don't currently apply to vSphere
credhub set -n /concourse/${FOUNDATION}/domain -t value -v "home.local"
credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "null" -w "null"

# vSphere section
# credhub set -n /concourse/main/pks_api_cert -t rsa -p ../pks.key -u ../pks.crt

# TODO 
# Have credhub generated the certs.
# Parameterize NSX IP

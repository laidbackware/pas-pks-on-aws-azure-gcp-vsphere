#!/bin/bash
# Script to set credhub secrets for pipelines.
# Certs must be generated and placed 1 level higher in the file system structure.
# Opmans public private pair, PKS API, PKS super user and Git private key.
# Remaining secrets will be pulled from lastpass.
# Secrets will print to the screen when run.

if [ $# -eq 0 ]; then
    echo "You must add your lastpass username as a parameter"
fi

set -euxo pipefail

# lpass login $1

# function finish {
#   lpass logout -f
# }
# trap finish EXIT

source ../ducc/1-vars.sh
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

download_attachmnents () {
    FILES=$(lpass show $1 |sed '1,2d')
    while  IFS= read -r line; do
        ATTACHMENT=$(echo "$line " | cut -d: -f1)
        echo "S" |lpass show aws-pks-api --attach=$ATTACHMENT
    done <<< $FILES
}

# inject certificate from Lastpass secure note attachments.
# Requires name of note and credhub path
set_rsa_from_attachment () {
    TMPDIR=$(mktemp -d) || exit 1
    echo "Temp dir is ${TMPDIR}"
    pushd $TMPDIR
    download_attachmnents $1
    PUBLIC=$(ls *.pem)
    PRIVATE=$(ls *.key)
    credhub set -n $2 -t rsa -p ./$PRIVATE -u ./$PUBLIC
    popd
}

# S3_ACCESS_KEY="$(lpass show s3_secret_access_key --password)"
PIVNET_TOKEN="$(lpass show pivnet_token --password)"
AWS_ACCESS_KEY="$(lpass show aws-paving-user --username)"
AWS_SECRET_KEY="$(lpass show aws-paving-user --password)"
GIT_PRIVATE_KEY="$(lpass show git_private_key --field="Private Key")"
OM_PASSWORD="$(lpass show opsman --password)"
AZURE_APP_ID="$(lpass show azure-principal --username)"
AZURE_SECRET="$(lpass show azure-principal --password)"
AZURE_TENANT_ID="$(lpass show azure-principal --notes |grep tenant_id: | cut -d " " -f2)"
AZURE_SUBSCRIPTION_ID="$(lpass show azure-principal --notes |grep subscription_id: | cut -d " " -f2)"
PKS_CLUSTER_ADMIN_USERNAME="$(lpass show pks_cluster_admin_user --username)"
PKS_CLUSTER_ADMIN_PASSWORD="$(lpass show pks_cluster_admin_user --password)"
VCENTER_USERNAME="$(lpass show lab_vcenter_creds --username)"
VCENTER_PASSWORD="$(lpass show lab_vcenter_creds --password)"
NSXT_LICENSE_KEY="$(lpass show nsxt_license_key --notes)"

AZURE_JSON="{}"

AWS_JSON="{\"client_id\": \"${AWS_ACCESS_KEY}\", \"client_secret\": \"${AWS_SECRET_KEY}\"}"

# Main section
VMWARE_DOWNLOAD_USER="$(lpass show vmware-download --username)"
VMWARE_DOWNLOAD_PASSWORD="$(lpass show vmware-download --password)"
credhub set -n /concourse/main/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
credhub set -n /concourse/main/pivnet_token -t password -w "$PIVNET_TOKEN"
credhub set -n /concourse/main/s3_secret_access_key -t password -w minio123
credhub set -n /concourse/main/vmware_download -t user -z "$VMWARE_DOWNLOAD_USER" -w "$VMWARE_DOWNLOAD_PASSWORD"

# AWS section
FOUNDATION=aws
DOMAIN="$(lpass show aws_domain --notes)"
PKS_API_PUBLIC_KEY=$(lpass show aws-pks-api --field=public_key)
PKS_API_PRIVATE_KEY=$(lpass show aws-pks-api --field=private_key)
GOROUTER_CA="$(lpass show aws-pas-gorouter --field=ca)"
GOROUTER_PUBLIC_KEY="$(lpass show aws-pas-gorouter --field=public_key)"
GOROUTER_PRIVATE_KEY="$(lpass show aws-pas-gorouter --field=private_key)"

CLOUD_CREDS_JSON="{\"client_id\": \"${AWS_ACCESS_KEY}\", \"client_secret\": \"${AWS_SECRET_KEY}\"}"
credhub set -n /concourse/${FOUNDATION}/decryption_passphrase -t password -w "${OM_PASSWORD}${OM_PASSWORD}"
credhub set -n /concourse/${FOUNDATION}/pivnet_token -t password -w "$PIVNET_TOKEN"
credhub set -n /concourse/${FOUNDATION}/s3_secret_access_key -t password -w minio123
credhub set -n /concourse/${FOUNDATION}/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
credhub set -n /concourse/${FOUNDATION}/om_login -t user -z admin -w "$OM_PASSWORD"
credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "$AWS_ACCESS_KEY" -w "$AWS_SECRET_KEY"
credhub set -n /concourse/${FOUNDATION}/cloud_creds -t json -v "${CLOUD_CREDS_JSON}"
credhub set -n /concourse/${FOUNDATION}/domain -t value -v "${DOMAIN}"
credhub set -n /concourse/${FOUNDATION}/pas_cert -t rsa  -p "${GOROUTER_PRIVATE_KEY}" -u "${GOROUTER_PUBLIC_KEY}"  -m "${GOROUTER_CA}"
#PKS Secrets
credhub set -n /concourse/${FOUNDATION}/pks-api -t rsa -p "${PKS_API_PRIVATE_KEY}" -u "${PKS_API_PUBLIC_KEY}"
credhub set -n /concourse/${FOUNDATION}/pks_cluster_admin_user -t user -z "$PKS_CLUSTER_ADMIN_USERNAME" -w "$PKS_CLUSTER_ADMIN_PASSWORD"

# Azure section
FOUNDATION=azure
DOMAIN="${FOUNDATION}.$(lpass show aws_domain --notes)"
CLOUD_CREDS_JSON="{\"client_id\": \"${AWS_ACCESS_KEY}\", \"client_secret\": \"${AWS_SECRET_KEY}\",
                                            \"azure_tenant_id\": \"${AZURE_TENANT_ID}\", 
                                            \"azure_subscription_id\": \"${AZURE_SUBSCRIPTION_ID}\"}" #TODO tenant sub
credhub set -n /concourse/${FOUNDATION}/decryption_passphrase -t password -w "${OM_PASSWORD}${OM_PASSWORD}"
credhub set -n /concourse/${FOUNDATION}/pivnet_token -t password -w "$PIVNET_TOKEN"
credhub set -n /concourse/${FOUNDATION}/s3_secret_access_key -t password -w minio123
credhub set -n /concourse/${FOUNDATION}/git_private_key -t ssh -p "$GIT_PRIVATE_KEY"
credhub set -n /concourse/${FOUNDATION}/om_login -t user -z admin -w "$OM_PASSWORD"
credhub set -n /concourse/${FOUNDATION}/cloud_creds -t json -v "${CLOUD_CREDS_JSON}"
# credhub set -n /concourse/${FOUNDATION}/azure_tenant_id -t value -v "${AZURE_TENANT_ID}"
# credhub set -n /concourse/${FOUNDATION}/azure_subscription_id -t value -v "${AZURE_SUBSCRIPTION_ID}"
credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "$AWS_ACCESS_KEY" -w "$AWS_SECRET_KEY"
credhub set -n /concourse/${FOUNDATION}/domain -t value -v "${DOMAIN}"
# PKS Secrets
credhub set -n /concourse/${FOUNDATION}/pks_cluster_admin_user -t user -z "$PKS_CLUSTER_ADMIN_USERNAME" -w "$PKS_CLUSTER_ADMIN_PASSWORD"

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
credhub set -n /concourse/${FOUNDATION}/opsman_ssh -t ssh -p ~/.ssh/opsman_ssh -u ~/.ssh/opsman_ssh.pub #TODO
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
credhub set -n /concourse/${FOUNDATION}/pks_api_cert -t rsa -p ../pks.key -u ../pks.crt
credhub set -n /concourse/${FOUNDATION}/pks_nsx_super_user -t rsa -p ../pks-super-user.key -u ../pks-super-user.crt #TODO
credhub set -n /concourse/${FOUNDATION}/pks_cluster_admin_user -t user -z "$PKS_CLUSTER_ADMIN_USERNAME" -w "$PKS_CLUSTER_ADMIN_PASSWORD"
# Below are to allow a single task to pave all IaaS and don't currently apply to vSphere
credhub set -n /concourse/${FOUNDATION}/domain -t value -v "home.local"
credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "null" -w "null"

# vSphere section
# credhub set -n /concourse/main/pks_api_cert -t rsa -p ../pks.key -u ../pks.crt

# TODO 
# Have credhub generated the certs.
# Parameterize NSX IP

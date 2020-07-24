#!/bin/bash
# To be used with the UAA Go Cli
# https://github.com/cloudfoundry-incubator/uaa-cli/releases
set -euxo pipefail

ROOT_DIR="$(pwd)"

pushd uaa-cli
chmod +x *linux*
cp *linux* /usr/local/bin/uaa
popd

pushd yq
chmod +x yq*
cp yq* /usr/local/bin/yq
popd

OM_TARGET=$(yq r ${ROOT_DIR}/config/vars/${FOUNDATION}/env.yml target)
PKS_ADDRESS=$(yq r ${ROOT_DIR}/config/vars/${FOUNDATION}/install-pks-vars.yml pks_api_hostname)

UAAC_SECRET=$(om -k -t ${OM_TARGET} credentials --product-name pivotal-container-service --credential-reference .properties.pks_uaa_management_admin_client --format=json | yq r - secret | tr -d '"')

uaa target https://${PKS_ADDRESS}:8443 --skip-ssl-validation

uaa get-client-credentials-token admin -s $UAAC_SECRET

set +e # Allow error on user already existing
uaa create-user  ${PKS_CLUSTER_ADMIN_USERNAME} --email ${PKS_CLUSTER_ADMIN_USERNAME}@pks.local --password ${PKS_CLUSTER_ADMIN_PASSWORD}

uaa add-member pks.clusters.admin ${PKS_CLUSTER_ADMIN_USERNAME}

exit 0
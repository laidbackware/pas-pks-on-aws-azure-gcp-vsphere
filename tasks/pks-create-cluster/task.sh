#!/bin/bash
# Create PKS clusters
set -euxo pipefail

ROOT_DIR="$(pwd)"

pushd pks-cli-linux
chmod +x *linux*
cp *linux* /usr/local/bin/pks
popd

pushd yq
chmod +x yq*
cp yq* /usr/local/bin/yq
popd

PKS_ADDRESS=$(yq r  ${ROOT_DIR}/config/vars/${FOUNDATION}/install-pks-vars.yml pks_api_hostname)

pks login -a ${PKS_ADDRESS} -u ${PKS_CLUSTER_ADMIN_USERNAME} -p "${PKS_CLUSTER_ADMIN_PASSWORD}" --skip-ssl-validation

CLUSTER_NAME=pks1
CLUSTER_ADDRESS="${CLUSTER_NAME}${PKS_ADDRESS/pks/}"
pks create-cluster pks1 --external-hostname ${CLUSTER_ADDRESS} -p small --json --wait


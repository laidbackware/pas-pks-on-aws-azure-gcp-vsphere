#!/bin/bash
# Script to set all pipelines

set -euxo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

FOUNDATION=$1

PKS_ADDRESS=$(yq r  ${SCRIPT_DIR}/vars/${FOUNDATION}/install-pks-vars.yml pks_api_hostname)
PKS_CLUSTER_ADMIN_USERNAME=$(credhub get -n /concourse/${FOUNDATION}/pks_cluster_admin_user -j |yq r - value.username | tr -d '"')
PKS_CLUSTER_ADMIN_PASSWORD=$(credhub get -n /concourse/${FOUNDATION}/pks_cluster_admin_user -j |yq r - value.password | tr -d '"')

pks login -a ${PKS_ADDRESS} -u ${PKS_CLUSTER_ADMIN_USERNAME} -p "${PKS_CLUSTER_ADMIN_PASSWORD}" --skip-ssl-validation
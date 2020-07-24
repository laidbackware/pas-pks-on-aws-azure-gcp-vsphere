#!/bin/bash

set -euxo pipefail

ROOT_DIR="$(pwd)"

if [ ${FOUNDATION} != "aws" ]; then
    echo "Not needed for platform type"
    exit 0
fi

trap 'rm -rf "$TMPDIR"' EXIT
TMPDIR=$(mktemp -d) || exit 1
echo "Temp dir is ${TMPDIR}"

TF_OUTPUT=$(ls ${ROOT_DIR}/tf-output-yaml/tf-output*)
bosh int ${TF_OUTPUT} --path /ops_manager_ssh_private_key |head -n -1 > ${TMPDIR}/om.key
eval "$(om bosh-env --ssh-private-key ${TMPDIR}/om.key)"

pushd addon
FILE_NAME=$(ls *.tgz)
RELEASE_VERSION=$(cat ${ROOT_DIR}/addon/version)
bosh upload-release ${FILE_NAME}
popd

pushd configuration/tasks/configure-bosh-addon
bosh update-runtime-config --name=${ADDON_NAME}_runtime runtime-config.yml \
--var=addon_name=${ADDON_NAME} --var=version=${RELEASE_VERSION} --non-interactive

# Post config confirmation
bosh configs
bosh runtime-config --name=${ADDON_NAME}_runtime


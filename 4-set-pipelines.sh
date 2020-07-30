#!/bin/bash
# Script to set all pipelines

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BRANCH="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"

fly -t main sp -n -p fetch-dependancies -c ${SCRIPT_DIR}/pipeline/download-pipeline.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -v branch=$BRANCH

# PKS not working
fly -t azure sp -n -p install-pks-azure -c ${SCRIPT_DIR}/pipeline/install-product-pipeline.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -l ${SCRIPT_DIR}/vars/azure/install-pks-vars.yml \
    -v branch=$BRANCH

# AWS
FOUNDATION=aws
fly -t ${FOUNDATION} sp -n -p install-pas-${FOUNDATION} -c ${SCRIPT_DIR}/pipeline/install-product-pipeline.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -l ${SCRIPT_DIR}/vars/${FOUNDATION}/install-pas-vars.yml \
    -v branch=$BRANCH
fly -t ${FOUNDATION} sp -n -p install-pks-${FOUNDATION} -c ${SCRIPT_DIR}/pipeline/install-product-pipeline.yml \
-l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -l ${SCRIPT_DIR}/vars/${FOUNDATION}/install-pks-vars.yml \
-v branch=$BRANCH

# vSphere
FOUNDATION=vsphere
fly -t ${FOUNDATION} sp -n -p prepare-vsphere-infra -c ${SCRIPT_DIR}/pipeline/prepare-vsphere-infra-pipeline.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -l ${SCRIPT_DIR}/vars/${FOUNDATION}/install-pks-vars.yml \
    -l ${SCRIPT_DIR}/vars/${FOUNDATION}/common-vars.yml -v branch=$BRANCH
fly -t ${FOUNDATION} sp -n -p install-pks-${FOUNDATION} -c ${SCRIPT_DIR}/pipeline/install-product-pipeline.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -l ${SCRIPT_DIR}/vars/${FOUNDATION}/install-pks-vars.yml \
    -l ${SCRIPT_DIR}/vars/${FOUNDATION}/common-vars.yml -v branch=$BRANCH

# PKS Post WIP
fly -t ${FOUNDATION} sp -n -p pks-post-install -c ${SCRIPT_DIR}/pipeline/pks-post-install.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -l ${SCRIPT_DIR}/vars/${FOUNDATION}/install-pks-vars.yml \
    -v branch=$BRANCH

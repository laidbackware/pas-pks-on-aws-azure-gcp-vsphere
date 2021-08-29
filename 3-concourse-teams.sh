#!/bin/bash
# Script to setup relevant Concourse teams

set -eu

source ../ducc/1-vars.sh
concourse_hostname=${DUCC_HOSTNAME_ENV:-$DUCC_HOSTNAME}

fly login -t main-ducc -c http://${concourse_hostname}:8080 -u admin -p ${DUCC_CONCOURSE_ADMIN_PASSWORD} -n main

TEAMS="aws azure gcp vsphere legacy"

for team in ${TEAMS}
do
    fly -t main-ducc set-team -n ${team} --local-user=admin --non-interactive
    fly login -t ${team} -c http://${concourse_hostname}:8080 -u admin -p ${DUCC_CONCOURSE_ADMIN_PASSWORD} -n ${team}
done
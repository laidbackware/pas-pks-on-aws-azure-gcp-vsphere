#!/bin/bash
# Script to setup relevant Concourse teams

source ../ducc/1-vars.sh

fly login -t main -c http://${DUCC_HOSTNAME}:8080 -u admin -p ${DUCC_CONCOURSE_ADMIN_PASSWORD} -n main

TEAMS="aws azure gcp vsphere legacy"

for team in ${TEAMS}
do
    fly -t main set-team -n ${team} --local-user=admin --non-interactive
    fly login -t ${team} -c http://${DUCC_HOSTNAME}:8080 -u admin -p ${DUCC_CONCOURSE_ADMIN_PASSWORD} -n ${team}
done
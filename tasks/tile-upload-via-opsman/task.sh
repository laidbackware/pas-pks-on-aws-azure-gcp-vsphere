#!/bin/bash

set -euxo pipefail

if [ ${IAAS_TYPE} = "vsphere" ]; then
    echo "Not needed for vsphere"
    cp state/om-state-*.yml generated-state/
    exit 0
fi

OM_TARGET=$(bosh int config/${ENV_FILE} --path /target | sed s"/((domain))/${OM_VAR_domain}/")

if $(curl -k --output /dev/null --silent --head --fail -m 5 ${OM_TARGET})
then
    echo "Ops Man is up"
else
    echo "Skipping task as Ops Man is not contactable and assumed to be deleted"
    cp state/om-state-*.yml generated-state/
    exit 0
fi

if [[ $(om -e config/${ENV_FILE} deployed-products -f json ) != "[]" ]]; then
    echo "There are still products deployed, refusing to delete Ops Man!\n Existing!"
    exit 1
fi

platform-automation-tasks/tasks/delete-vm.sh

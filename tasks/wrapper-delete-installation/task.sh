#!/bin/bash

set -euxo pipefail

if [ ${IAAS_TYPE} = "vsphere" ]; then
    echo "Not needed for vsphere"
    exit 0
fi

OM_TARGET=$(bosh int config/${ENV_FILE} --path /target | sed s"/((domain))/${OM_VAR_domain}/")

if $(curl -k --output /dev/null --silent --head --fail -m 5 ${OM_TARGET})
then
    echo "Ops Man is up"
else
    echo "Skipping task as Ops Man is not contactable and assumed to be deleted"
    exit 0
fi

platform-automation-tasks/tasks/delete-installation.sh

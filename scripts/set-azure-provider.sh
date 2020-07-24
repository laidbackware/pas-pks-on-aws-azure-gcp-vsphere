#!/bin/bash

# Must already be logged into Azure
# Must have exported 

set -euxo pipefail

AZ_PASS=""
PREFIX=mproud

#TODO abort if more than 1 tenant
SUBSCRIPTION_ID="$(az account list |jq -r .[0].tenantId)"
TENANT_ID="$(az account list |jq -r .[0].id)"

CREATE_RESPONSE=$(az ad app create --display-name "${PREFIX} - Service Principal for BOSH" \
--password "${AZ_PASS}" --homepage "http://BOSHAzureCPI" \
--identifier-uris "http://${PREFIX}BOSHAzureCPI") || exit $?

APP_ID="$(echo ${CREATE_RESPONSE} |jq -r .appId)"

az ad sp create --id ${APP_ID}

ROLE_RESPONSE=$(az role assignment create --assignee "SERVICE-PRINCIPAL-NAME" \
--role "Owner" --scope "/subscriptions/${SUBSCRIPTION_ID}")

az role assignment list --assignee "SERVICE-PRINCIPAL-NAME"


az login --username ${APP_ID} --password "${AZ_PASS}" \
--service-principal --tenant ${TENANT_ID}

az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute

#!/bin/bash
set -euxo pipefail

ROOT_DIR=$(pwd)
cp ${ROOT_DIR}/jq-cli/jq-* /usr/local/bin/jq
chmod +x /usr/local/bin/jq 

cd downloaded-product
LATEST_URL=$(curl https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n -k 5,5n | egrep -v 'rc|beta|alpha' | egrep 'linux.*amd64' |tail -1)
LATEST_VERSION=$(curl https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].version' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n -k 5,5n | egrep -v 'rc|beta|alpha' |tail -1)
curl ${LATEST_URL} --output terraform.zip
unzip terraform.zip
rm terraform.zip
mv terraform ${ROOT_DIR}/downloaded-product/terraform-${LATEST_VERSION}

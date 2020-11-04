#!/bin/sh
set -euxo pipefail

DOWNLOAD_DIR="$(pwd)/downloaded-product"

PRODUCT_FILES="$(vmw-cli ls ${PRODUCT_DIRECTORY})"

FILE_NAME="$(echo "${PRODUCT_FILES}" |grep ${FILE_REGEX} |cut -d " " -f1)"

if [ `echo "${FILE_NAME}" |wc -l` -ge 2 ]
then
    echo "The glob must only return 1 result"
    echo "The following results were returned: \n${FILE_NAME}"
    echo "Exiting"
    exit 1
fi

vmw-cli cp "${FILE_NAME}"

cp /files/* ${DOWNLOAD_DIR}

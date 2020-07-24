#!/bin/bash
set -euxo pipefail

cd downloaded-product
wget -O ${OUTPUT_FILE_NAME} ${DOWNLOAD_LINK}

chmod +x ${OUTPUT_FILE_NAME}
VER=$(eval ${VERSION_CHECK_COMMAND})
mv ${OUTPUT_FILE_NAME} ${OUTPUT_FILE_NAME}-${VER}

#!/bin/bash
set -euxo pipefail

minio_hostname=${DUCC_HOSTNAME_ENV:-localhost}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if ! command -v mc; then
    wget -O /tmp/mc https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x /tmp/mc
    mv /tmp/mc /usr/local/bin/
fi
echo "$(mc -v)"


if ! command -v yq; then
    curl -s https://api.github.com/repos/mikefarah/yq/releases/latest \
    | grep "browser_download_url.*yq_linux_amd64" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -qi -
    chmod +x ./yq*
    mv ./yq* /usr/local/bin/yq
fi

mc config host add docker http://${minio_hostname}:9080 minio minio123 --api "s3v4"

BUCKET_FILE=${SCRIPT_DIR}/vars/download-vars/download-vars.yml
BUCKETS=$(yq e  '.buckets.*' ${BUCKET_FILE})

for bucket in ${BUCKETS}
do
    mc mb docker/${bucket} -p
done
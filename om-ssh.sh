#!/bin/bash

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "You must add the foundation name"
fi

S3_OPTIONS='--access_key=minio --secret_key=minio123 --no-ssl --region=us-east-1 --host=192.168.0.3:9080 --host-bucket=192.168.0.3:9080 --signature-v2'

trap 'rm -rf "$TMPDIR"' EXIT
TMPDIR=$(mktemp -d) || exit 1
echo "Temp dir is ${TMPDIR}"

pushd $TMPDIR

s3cmd ${S3_OPTIONS}  -r get s3://terraform-state/ .

# cd $1

OUTPUT_FILE=$(ls -dt  $1/tf-output* | head -1)



tree
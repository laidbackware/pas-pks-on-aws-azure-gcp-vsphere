#!/bin/bash
# Add OQ to path location and make executable

set -euxo pipefail

pushd oq
chmod +x oq*
cp oq* /usr/local/bin/oq
popd

pushd jq
chmod +x jq*
cp jq* /usr/local/bin/jq
popd
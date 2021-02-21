#!/bin/bash

CACHE_DIR="${HOME}/cache"
FILE_DIR="shadowsocks-libev"
FILE_NAME="Changes"

ls -alh ${CACHE_DIR}
ls -alh ${FILE_DIR}

if [ -f "${CACHE_DIR}/${FILE_NAME}" ]
then
    echo "file exists"
    exit 0
fi

set -e

mkdir -p ${CACHE_DIR}
cp ${FILE_DIR}/${FILE_NAME} ${CACHE_DIR}

curl --request POST \
    --header "Content-Type: application/json" \
    --data '{"source_type": "Branch", "source_name": "${DOCKERHUB_BUILD_BRANCH}"}' \
    ${DOCKERHUB_BUILD_TRIGGER}
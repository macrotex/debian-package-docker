#!/usr/bin/env bash

# Run the docker container

DEBIAN_RELEASE='bookworm'

LOCAL_BUILD_DIRECTORY=$(mktemp -d)
TARGET_BUILD_DIRECTORY=/root/build

LOCAL_OUTPUT_DIRECTORY=$(mktemp -d)
TARGET_OUTPUT_DIRECTORY=/root/output

DEBIAN_PKG_GIT_URL=https://github.com/macrotex/debian-native-package.git
git clone $DEBIAN_PKG_GIT_URL $LOCAL_BUILD_DIRECTORY

docker run \
       --env BUILD_DIRECTORY=$TARGET_BUILD_DIRECTORY \
       --env OUTPUT_DIRECTORY=$TARGET_OUTPUT_DIRECTORY \
       --env VERBOSE=XXX \
       --mount type=bind,source=$LOCAL_BUILD_DIRECTORY,target=$TARGET_BUILD_DIRECTORY \
       --mount type=bind,source=$LOCAL_OUTPUT_DIRECTORY,target=$TARGET_OUTPUT_DIRECTORY \
       debian-package:$DEBIAN_RELEASE

# Clean up...
rm -rf $LOCAL_BUILD_DIRECTORY

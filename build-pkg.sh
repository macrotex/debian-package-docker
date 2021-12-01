#!/bin/bash

set -e

# Check for required environment variables.
if [ "$BUILD_DIRECTORY" = "" ]; then
   echo "missing required environment variable BUILD_DIRECTORY"
   exit 1
fi

if [ ! -d "$BUILD_DIRECTORY" ]; then
   echo "BUILD_DIRECTORY '$BUILD_DIRECTORY' does not exist"
   exit 1
fi

if [ ! -z "$OUTPUT_DIRECTORY" ]; then
    if [ ! -d "$OUTPUT_DIRECTORY" ]; then
        echo "OUTPUT_DIRECTORY '$OUTPUT_DIRECTORY' does not exist"
        exit 1
    fi
    echo "will leave all build artificates in $OUTPUT_DIRECTORY"
fi

cd "$BUILD_DIRECTORY"

# Step 1. Install any build dependencies
echo ">> run install-dependencies.sh"
/root/install-dependencies.sh

# Step 2. Build the package.
echo ">> run run-dpkg-buildpackage.sh"
/root/run-dpkg-buildpackage.sh

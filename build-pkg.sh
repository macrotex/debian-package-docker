#!/bin/bash

set -e

## #### #### #### #### #### #### #### #### ##
progress () {
    local message
    message=$1
    echo "progress: $message"
}
exit_with_error () {
    local message
    message=$1
    echo "error: $message"
    exit 1
}
## #### #### #### #### #### #### #### #### ##

# 0. Error checking.
if [[ -z "$BUILD_DIRECTORY" ]]; then
   exit_with_error "missing required environment variable BUILD_DIRECTORY"
elif [[ ! -d "$BUILD_DIRECTORY" ]]; then
   exit_with_error "BUILD_DIRECTORY '$BUILD_DIRECTORY' does not exist"
else
    progress "using BUILD_DIRECTORY '$BUILD_DIRECTORY' as the build directory"
fi

if [[ ! -z "$OUTPUT_DIRECTORY" ]]; then
    if [[ ! -e "$OUTPUT_DIRECTORY" ]]; then
        exit_with_error "OUTPUT_DIRECTORY ($OUTPUT_DIRECTORY) does not exist"
    elif [[ ! -d "$OUTPUT_DIRECTORY" ]]; then
        exit_with_error "OUTPUT_DIRECTORY ($OUTPUT_DIRECTORY) is not a directory"
    else
        progress "OUTPUT_DIRECTORY ($OUTPUT_DIRECTORY) exists and is a directory"
        progress "will leave all build artifacts in $OUTPUT_DIRECTORY"
    fi
fi

if [[ ! -z "$DPUT_CF" ]]; then
    if [[ ! -e "$DPUT_CF" ]]; then
        exit_with_error "file DPUT_CF ($DPUT_CF) does not exist"
    elif [[ ! -f "$DPUT_CF" ]]; then
        exit_with_error "DPUT_CF ($DPUT_CF) is not a file"
    elif [[ -z "$DPUT_HOST" ]]; then
        exit_with_error "if DPUT_CF is set you must also supply DPUT_HOST"
    else
        progress "DPUT_CF ($DPUT_CF) exists and is a file"
    fi

    echo "will leave all build artificats in $OUTPUT_DIRECTORY"
fi

cd "$BUILD_DIRECTORY"

# Step 1. Install any build dependencies
echo ">> run install-dependencies.sh"
/root/install-dependencies.sh

# Step 2. Build the package.
echo ">> run run-dpkg-buildpackage.sh"
/root/run-dpkg-buildpackage.sh

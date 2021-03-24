#!/bin/bash

set -e

# 1. Create a temporary place where we can build the package.
echo "creating temporary directory..."
mkdir /tmp/build
tmp_dir=$(mktemp -d -p /tmp/build -t build-XXXX)

# 2. Copy everything into the temporary directory.
echo "copying $BUILD_DIRECTORY into temporary directory..."
cp -pR $BUILD_DIRECTORY/. $tmp_dir/

# 3. Build the package in $tmp_dir.
echo "building package in $tmp_dir..."
cd $tmp_dir
dpkg-buildpackage

# 4. Run lintian (maybe).
if [ ! -z "$RUN_LINTIAN" ]; then
    echo "running lintian..."
    lintian --allow-root -i ../*.changes
else
    echo "skipping lintian..."
fi

# 5. Clean up.
echo "cleaning up..."
cd
rm -rf /tmp/build

exit 0

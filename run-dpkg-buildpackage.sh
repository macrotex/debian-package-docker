#!/bin/bash

set -e

# 1. Create a temporary place where we can build the package.
echo "create temporary directory..."
mkdir /tmp/build
tmp_dir=$(mktemp -d -p /tmp/build -t build-XXXX)

# 2. Copy everything into the temporary directory.
echo "copy $BUILD_DIRECTORY into temporary directory..."
cp -pR $BUILD_DIRECTORY/. $tmp_dir/

# 3. Build the package in $tmp_dir.
echo "build package in $tmp_dir..."
cd $tmp_dir
dpkg-buildpackage

# 4. Clean up.
echo "clean up..."
cd
rm -rf /tmp/build

exit 0

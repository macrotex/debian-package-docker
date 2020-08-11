#!/bin/sh

set -e

cd /root/debian

# Step 1. Install any build dependencies
echo "run install-dependencies.sh"
/root/install-dependencies.sh

# Step 2. Build the package.
echo "run dpkg-buildpackage"
dpkg-buildpackage

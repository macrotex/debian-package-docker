#!/usr/bin/env bash

# A script to build the debian-package images for several Debian
# releases.

set -e

# The list of Debian releases we build for:
releases=('buster' 'bullseye' 'bookworm' 'sid')

for release in "${releases[@]}"; do
    echo "building '$release' Docker image..."
    docker build --build-arg DEBIAN_DISTRIBUTION="$release"-slim --tag debian-package:"$release" .
done

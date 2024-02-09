#!/bin/sh

DEBIAN_RELEASE='bookworm'
docker build .    \
       --file=Dockerfile \
       --build-arg DEBIAN_DISTRIBUTION=${DEBIAN_RELEASE}-slim \
       --tag debian-package:$DEBIAN_RELEASE

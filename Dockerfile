# A container to build Debian packages

# 0. We start with the "slim" version of Debian.
FROM debian:buster-slim
LABEL maintainer github238@macrotex.net

# 1. Install the packages needed for building.
RUN   apt-get update \
   && apt-get install -y --no-install-recommends \
        build-essential \
        devscripts      \
        fakeroot        \
        debhelper       \
        perl            \
   && apt-get clean

# 2. Add the package script. This script changes to
# /root/debian and builds the package it expects to find there.
ADD install-dependencies.sh /root/install-dependencies.sh
ADD build-pkg.sh            /root/build-pkg.sh

# FINALLY. Run the package build script
CMD /root/build-pkg.sh

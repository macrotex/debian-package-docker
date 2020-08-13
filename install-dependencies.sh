#!/bin/bash

# Because of the "set -e" we have to "or" several of the commands with true.
set -e

export DPKG_COLORS=never

DEPENDENCIES_RAW=$(dpkg-checkbuilddeps 2>&1 || true)
DEPENDENCIES_RAW=$(echo "$DEPENDENCIES_RAW" | grep 'Unmet build dependencies' || true)

DEPENDENCIES=$(echo "$DEPENDENCIES_RAW" | perl -n -e 'if (m{dependencies: (.*)$}) { print "$1\n"; }' -n)

# Remove any leading or trailing spaces.
DEPENDENCIES=$(echo $DEPENDENCIES | sed -e 's/^[[:space:]]*//')
DEPENDENCIES=$(echo $DEPENDENCIES | sed -e 's/[[:space:]]*$//')

if [[ -z "$DEPENDENCIES" ]]; then
   echo "no build dependencies to install"
else
   echo "about to install dependencies:"
   echo "$DEPENDENCIES"
   apt-get update
   # shellcheck disable=SC2086
   apt-get install -y --no-install-recommends $DEPENDENCIES
fi

exit 0

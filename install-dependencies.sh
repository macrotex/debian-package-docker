#!/usr/bin/env bash

# We disable shellcheck's SC200l as I could not get this script to work
# with SC2001's suggestion.
# shellcheck disable=SC2001

# Because of the "set -e" we have to "or" several of the commands with true.
set -e

## #### #### #### #### #### #### #### #### ##
progress () {
    local message
    if [[ -n "$VERBOSE" ]]; then
        message=$1
        echo "progress: $message"
    fi
}
## #### #### #### #### #### #### #### #### ##

export DPKG_COLORS=never

DEPENDENCIES_RAW=$(dpkg-checkbuilddeps 2>&1 || true)
DEPENDENCIES_RAW=$(echo "$DEPENDENCIES_RAW" | grep 'Unmet build dependencies' || true)
progress "DEPENDENCIES_RAW is '$DEPENDENCIES_RAW'"

DEPENDENCIES=$(perl /root/extract-dependencies.pl "$DEPENDENCIES_RAW")
progress "DEPENDENCIES is '$DEPENDENCIES'"

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

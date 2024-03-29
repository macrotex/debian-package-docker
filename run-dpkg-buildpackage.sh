#!/usr/bin/env bash

# The shellcheck utility thinks some of the code is unreachable when it's
# not, so tell it to be quiet about it.
# shellcheck disable=SC2317

set -e

SCRIPT_VERSION="5"

## #### #### #### #### #### #### #### #### ##
progress () {
    local message
    if [[ -n "$VERBOSE" ]]; then
        message=$1
        echo "progress: $message"
    fi
}

progress_show_env () {
    local env_name
    env_name=$1

    local value
    value="${!env_name}"

    if [[ -z ${!env_name+x} ]]; then
        msg="<not set>"
    elif [[ "$value" == "" ]]; then
        msg="<empty string>"
    else
        msg="$value"
    fi

    progress "$env_name: $msg"
}

exit_with_error () {
    local message
    message=$1
    echo "error: $message"
    exit 1
}
## #### #### #### #### #### #### #### #### ##

progress "SCRIPT_VERSION is $SCRIPT_VERSION"

progress_show_env "BUILD_DIRECTORY"
progress_show_env "RUN_LINTIAN"
progress_show_env "DPUT_CF"
progress_show_env "DPUT_HOST"
progress_show_env "OUTPUT_DIRECTORY"
progress_show_env "VERBOSE"
progress_show_env "USER"
progress_show_env "EMAIL"
progress_show_env "DEBEMAIL"
progress_show_env "EMAIL"
progress_show_env "DEBFULLNAME"

# 1. Create a temporary place where we can build the package.
progress "creating temporary directory..."
mkdir /tmp/build
tmp_dir=$(mktemp -d -p /tmp/build -t build-XXXX)

# 2. Copy everything into the temporary directory.
progress "copying $BUILD_DIRECTORY into temporary directory..."
cp -pR "$BUILD_DIRECTORY/." "$tmp_dir/"

# 3. Build the package in $tmp_dir.
progress "building package in $tmp_dir..."
cd "$tmp_dir"
dpkg-buildpackage --no-sign

# 4. Run lintian (maybe).
# We use the "--allow-root" option to override lintian's warning when it
# is run with superuser privileges.
if [[ -n "$RUN_LINTIAN" ]]; then
    progress "running lintian..."
    lintian --allow-root -i ../*.changes
else
    progress "skipping lintian..."
fi

# 5. If DPUT_CF is set run dput (error checking on DPUT_CF
# happened in the script that called this script).
if [[ -n "$DPUT_CF" ]]; then
    progress "running dput with configuration file $DPUT_CF"

    if [[ -n "$VERBOSE" ]]; then
        progress "dumping dput.cf file $DPUT_CF"
        echo "#################################################"
        cat "$DPUT_CF"
        echo "#################################################"
    fi

    cd "$tmp_dir"
    cd ..
    if [[ -z "$VERBOSE" ]]; then
        debug_flag=""
    else
        debug_flag="--debug"
    fi

    # If the dput fails don't abort script.
    dput "$debug_flag" -c "$DPUT_CF" -- "$DPUT_HOST" *.changes || /bin/true

    if [[ -n "$VERBOSE" ]]; then
        echo "displaying contents of the .upload file"
        echo "#################################################"
        cat -- *upload
        echo "#################################################"
    fi

else
    progress "DPUT_CF not defined so skipping dput..."
fi

# 6. If OUTPUT_DIRECTORY is defined, copy everything into it.
if [[ -n "$OUTPUT_DIRECTORY" ]]; then
    progress "copying everything into OUTPUT_DIRECTORY ($OUTPUT_DIRECTORY)..."
    cd "$tmp_dir"
    find .. -type f -execdir cp "{}" "$OUTPUT_DIRECTORY" ";"
    #
    # Print out the package build artifact files.
    source=$(dpkg-parsechangelog  -l "$BUILD_DIRECTORY/debian/changelog" | grep Source  | cut -f2 -d':' | tr -d ' ')
    version=$(dpkg-parsechangelog -l "$BUILD_DIRECTORY/debian/changelog" | grep Version | cut -f2 -d':' | tr -d ' ')
    build_files_prefix="${source}_${version}"
    echo "------------------------------"
    echo "Your output directory contains these Debian package files:"
    ls "$OUTPUT_DIRECTORY/${build_files_prefix}"*
else
    progress "OUTPUT_DIRECTORY not defined so skipping copying..."
fi

# 7. Clean up.
progress "cleaning up..."
cd
rm -rf /tmp/build

exit 0

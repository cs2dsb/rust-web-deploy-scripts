#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

# Check we have have root privs
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

cd "${BASH_SOURCE%/*}"
source "../setup/variables.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

SOURCE=${1:-}
DESTINATION=${2:-}
OVERWRITE=${3:-}

function usage() {
    echo "user-application requires at least 2 arguments (source directory, destination directory, [overwite (use \"true\")])" 1>&2
    if [ "${1:-}" != "" ]; then
        echo "    $1" 1>&2
    fi
    exit 1
}


# Reject empty args
[ "$DESTINATION" == "" ] && usage "destination required"

# Reject missing source
! test -d $SOURCE >/dev/null 2>&1 && usage "source directory \"${SOURCE}\" does not exist"

# Exit if destination exists and overwrite is not true
if test -d "$DESTINATION" >/dev/null 2>&1 && [ "$OVERWRITE" != "true" ]; then
    echo "Application already exists. Not deploying"
    exit 0
fi

mkdir -p $DESTINATION


# Check the user exists
if ! id "${APP_ACCOUNT}" &>/dev/null; then
    echo "app-user-creation must be run before user-application (${APP_ACCOUNT} user doesn't exist)" 1>&2
    exit 1
fi

rsync -a --info=progress2 $SOURCE/ $DESTINATION/

# Set ownership now in case post-install depends on it
chown -R $APP_ACCOUNT:$APP_ACCOUNT $DESTINATION

# If there is a post install script in the artifacts, run it
POST_INSTALL="$DESTINATION/post-install.sh"
if test -f "$POST_INSTALL" >/dev/null 2>&1; then
    "$POST_INSTALL"
fi

# Set ownership now in case post-install created some files as the current (root) user
chown -R $APP_ACCOUNT:$APP_ACCOUNT $DESTINATION

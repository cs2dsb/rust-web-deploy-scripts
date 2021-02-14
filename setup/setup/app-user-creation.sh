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
source "./variables.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

if [ "$APP_ACCOUNT" == "" ]; then
    echo "APP_ACCOUNT is mandatory for app-user-creation to work" 1>&2
    exit 1
fi

# Create the user
if ! id "${APP_ACCOUNT}" &>/dev/null; then
    useradd -r ${APP_ACCOUNT}
fi

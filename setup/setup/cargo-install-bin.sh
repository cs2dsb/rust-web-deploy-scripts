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


function usage() {
    echo "cargo-install-bin requires at least 1 argument (bin, [package], [features] (package is mandatory if features are required))" 1>&2
    if [ "${1:-}" != "" ]; then
        echo "    $1" 1>&2
    fi
    exit 1
}

BIN=${1:-}
PACKAGE=${2:-}
FEATURES=${3:-}

# Reject empty args
[ "$BIN" == "" ] && usage "bin name required"

if [ "$PACKAGE" = "" ]; then
    PACKAGE=$BIN
fi

if [ "$FEATURES" = "" ]; then
    FEATURES="default"
fi

if ! command -v "$BIN" >/dev/null 2>&1; then
    echo "Installing $BIN"
    cargo install $PACKAGE --root /usr/local --no-default-features --features $FEATURES
fi

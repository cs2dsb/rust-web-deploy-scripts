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
source "../setup/apt-functions.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

apt_install openssl

openssl dhparam -out dhparams.pem 4096
if [ "$OUT_OVERRIDE" == "" ]; then
    mkdir -p $HAPROXY_BASE
    mv dhparams.pem "$HAPROXY_DHPARAMS"
else
    mv dhparams.pem "$OUT_OVERRIDE"
fi

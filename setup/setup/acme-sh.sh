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
source "./apt-functions.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

apt_install socat

if test -f "${ACMESH_BIN}" >/dev/null 2>&1; then
    exit 0
fi

# Download the latest release
curl -sL https://api.github.com/repos/acmesh-official/acme.sh/releases/latest \
    | grep "tarball_url" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | tr -d , \
    | wget -q -O acme-sh.tar.gz -i -

# Unpack it
mkdir -p acme-sh && tar -xzf acme-sh.tar.gz -C acme-sh --strip-components 1

# Clean up the archive
rm acme-sh.tar.gz

# Install
cd acme-sh
./acme.sh --install --auto-upgrade

# Clean up the unpacked files
cd ..
rm -rf acme-sh

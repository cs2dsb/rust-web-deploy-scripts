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

if command -v rustc >/dev/null 2>&1; then
    exit 0
fi

# Download the correct version
RELEASE="rust-${RUST_VERSION}-${RUST_TARGET}"
ARCHIVE="${RELEASE}.tar.gz"
wget -q "https://static.rust-lang.org/dist/${ARCHIVE}"

# Unpack it
tar -xzf ${ARCHIVE}

# Clean up the archive
rm ${ARCHIVE}

# Install
cd ${RELEASE}
./install.sh

# Clean up the unpacked files
cd ..
rm -rf ${RELEASE}

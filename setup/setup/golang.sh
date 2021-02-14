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

source "${BASH_SOURCE%/*}/variables.sh"
source "${BASH_SOURCE%/*}/apt-functions.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

if command -v go >/dev/null 2>&1; then
    exit 0
fi

# Download the latest stable release
wget -q "https://dl.google.com/go/$(curl -s https://golang.org/VERSION?m=text).linux-amd64.tar.gz"

# Extract it to /usr/local
sudo tar -C /usr/local -xzf go*.tar.gz

# Clean up the archive
rm go*.tar.gz

# Add to path if not there
GO_PATH=/usr/local/go/bin
if ! grep -q "$GO_PATH" $GLOBAL_PROFILE ; then
    echo 'export PATH="'${GO_PATH}':$PATH"' >> $GLOBAL_PROFILE
fi

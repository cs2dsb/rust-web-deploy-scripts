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
source "./firewall-functions.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

apt_install ufw

ufw default deny incoming
ufw default allow outgoing


if [ "$USE_WIREGUARD" == "true" ] && ufw status | grep -q "$WIREGUARD_PORT/udp"; then
    SKIP_22=true
fi

if [ "SKIP_22" != "true" ]; then
    firewall_allow_port 22
fi

echo "y" | ufw enable

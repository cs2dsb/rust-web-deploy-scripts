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

RESET_CONF=false
if ! command -v haproxy >/dev/null 2>&1; then
    RESET_CONF=true
fi

apt_install_ppa haproxy vbernat/haproxy-2.0 "haproxy=${HAPROXY_VERSION}.*"

firewall_allow_port 80
firewall_allow_port 443

if [ "$RESET_CONF" = true ]; then
    # Install a configuration that just supports acme
    cp "../config/haproxy/haproxy-acme-only.cfg" "$HAPROXY_CONFIG"
fi

# Restart the service to make the config active
systemctl restart haproxy.service

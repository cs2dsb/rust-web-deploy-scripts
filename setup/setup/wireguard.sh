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
source "./apt-functions.sh"
source "./firewall-functions.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

if [ "$USE_WIREGUARD" != true ]; then
    exit 0
fi

apt_install wg wireguard

# Skip if it's already set up
if test -f "$WIREGUARD_CONF" &>/dev/null; then
    exit 0
fi


SPRI="../config/wireguard/server_private_key"
CPUB="../config/wireguard/client_public_key"

if ! test -f "$CPUB" >/dev/null 2>&1 || ! test -f "$SPRI" >/dev/null 2>&1; then
    echo "wireguard setup requires a server_private_key and a client_public_key" 1>&2
    exit 1
fi

SERVER_PRIVATE_KEY=`cat $SPRI`
CLIENT_PUBLIC_KEY=`cat $CPUB`

TEMPLATE="../config/wireguard/wg0-server-conf.template"
ALLOWED=`sed -n 's/^AllowedIPs = //p' "$TEMPLATE"`

cp "$TEMPLATE" "$WIREGUARD_CONF"
chmod 600 "$WIREGUARD_CONF"

sed -i "s!{port}!${WIREGUARD_PORT}!g" "$WIREGUARD_CONF"
sed -i "s!{server_private_key}!${SERVER_PRIVATE_KEY}!g" "$WIREGUARD_CONF"
sed -i "s!{client_public_key}!${CLIENT_PUBLIC_KEY}!g" "$WIREGUARD_CONF"

firewall_allow_port "${WIREGUARD_PORT}/udp"
firewall_allow_from "$ALLOWED"

systemctl enable wg-quick@wg0.service
systemctl start wg-quick@wg0.service

firewall_remove_allow_port 22

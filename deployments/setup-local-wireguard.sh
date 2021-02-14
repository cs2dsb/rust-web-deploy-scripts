#!/usr/bin/env bash

#
# Params:
#   $1 = server dns/ip address
#   $2 = deployment name
#

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

source "${BASH_SOURCE%/*}/../setup/setup/variables.sh"

ADDRESS=${1:-}
DEPLOYMENT=${2:-}


if [ "$ADDRESS" = "" ] || [ "$DEPLOYMENT" = "" ]; then
    echo "setup-local-wireguard requires 2 arguments (hostname/address, deployment name)" 1>&2
    exit 1
fi

if ! test -d "$DEPLOYMENT" >/dev/null 2>&1; then
    echo "\"$DEPLOYMENT\" dir not found" 1>&2
    exit 1
fi

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

if [ "$USE_WIREGUARD" != true ]; then
    exit 0
fi

if ! command -v wg >/dev/null 2>&1; then
    echo "wg command not available. Install wireguard (try apt-get install wireguard if you are on a debian based system)" 1>&2
    exit 1
fi

N=`ls -1q /etc/wireguard/ | wc -l`
WG="wg-client$N"
CONF="/etc/wireguard/$WG.conf"
SPUB="$DEPLOYMENT/config/wireguard/server_public_key"
CPRI="$DEPLOYMENT/config/wireguard/client_private_key"

if ! test -f "$SPUB" >/dev/null 2>&1 || ! test -f "$CPRI" >/dev/null 2>&1; then
    echo "wireguard setup requires \"$SPUB\" and \"$CPRI\"" 1>&2
    exit 1
fi

CLIENT_PRIVATE_KEY=`cat $CPRI`
SERVER_PUBLIC_KEY=`cat $SPUB`

SOURCE="$DEPLOYMENT/config/wireguard/wg0-client-conf.template"
if ! test -f "$SOURCE" >/dev/null 2>&1; then
    SOURCE="${BASH_SOURCE%/*}/../setup/config/wireguard/wg0-client-conf.template"
fi

cp "$SOURCE" "$CONF"
chmod 600 "$CONF"

sed -i "s!{port}!${WIREGUARD_PORT}!g" "$CONF"
sed -i "s!{client_private_key}!${CLIENT_PRIVATE_KEY}!g" "$CONF"
sed -i "s!{server_public_key}!${SERVER_PUBLIC_KEY}!g" "$CONF"
sed -i "s!{host}!${ADDRESS}!g" "$CONF"

systemctl restart wg-quick@$WG.service
#systemctl enable wg-quick@$WG.service

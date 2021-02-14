#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

source "${BASH_SOURCE%/*}/variables.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

if [ "$USE_WIREGUARD" != true ]; then
    exit 0
fi

DEPLOYMENT=${1:-}
if ! test -d "$DEPLOYMENT" >/dev/null 2>&1; then
    echo "\"$DEPLOYMENT\" dir not found" 1>&2
    exit 1
fi

WG_CONFIG="$DEPLOYMENT/config/wireguard"
mkdir -p $WG_CONFIG

CPUB="$WG_CONFIG/client_public_key"
CPRI="$WG_CONFIG/client_private_key"
SPUB="$WG_CONFIG/server_public_key"
SPRI="$WG_CONFIG/server_private_key"

if ! test -f "$CPUB" >/dev/null 2>&1 && ! test -f "$CPRI" >/dev/null 2>&1 && ! test -f "$SPUB" >/dev/null 2>&1 && ! test -f "$SPRI" >/dev/null 2>&1; then
    if ! command -v wg >/dev/null 2>&1; then
        echo "wg command not available. Install wireguard (try apt-get install wireguard if you are on a debian based system)" 1>&2
        exit 1
    fi

    echo "Generating keys"
    umask 077
    wg genkey | tee "$SPRI" | wg pubkey > "$SPUB"
    wg genkey | tee "$CPRI" | wg pubkey > "$CPUB"
fi

#USE_WIREGUARD

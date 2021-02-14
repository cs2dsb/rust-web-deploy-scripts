#!/usr/bin/env bash

# Changes the hostname and updates hosts
#
# Args:
#   1 - new hostname

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

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

NAME=${1:-}

function usage() {
    echo "hostname requires 1 argument (new hostname)" 1>&2
    exit 1
}

# Reject empty args
[ "$NAME" = "" ] && usage

OLD_NAME="$HOSTNAME"
[ "$OLD_NAME" = "" ] && usage "failed to get previous hostname"

# Nothing to do if they are the same
echo $OLD_NAME $NAME
[ "$OLD_NAME" = "$NAME" ] && exit 0

hostnamectl set-hostname "$NAME"
sed -i "s+${OLD_NAME}+${NAME}+g" "/etc/hosts"

echo "Rebooting to finalize hostname change"
reboot

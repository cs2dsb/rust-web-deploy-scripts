#!/usr/bin/env bash

# Creates a simple systemd service
#
# Args:
#   1 - app name
#   2 - app dir path
#   3 - bin name (assumed to be immediatly under path above)

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
WD=${2:-}
BIN=${3:-}

function usage() {
    echo "systemd-service requires at 3 arguments (app name, working dir, bin name)" 1>&2

    if [ "${1:-}" != "" ]; then
        echo "    $1" 1>&2
    fi

    exit 1
}

function service_exists() {
    name=$1

    if [[ $(systemctl list-units --all -t service --full --no-legend "$name.service" | cut -f1 -d' ') == "$name.service" ]]; then
        return
    fi

    false
}

# Reject empty args
[ "$NAME" == "" ] && usage "name is required"

# Skip if the service has already been registered
if service_exists "$NAME"; then
    exit 0
fi

# Reject missing dir
! test -d "$WD" >/dev/null 2>&1 && usage "working dir must exist and be a directory"

# or bin
! test -f "$WD/$BIN" >/dev/null 2>&1 && usage "working dir\\bin must exist and be a file"

# Check the user exists
if ! id "${APP_ACCOUNT}" &>/dev/null; then
    echo "app-user-creation must be run before user-application (${APP_ACCOUNT} user doesn't exist)" 1>&2
    exit 1
fi


SVC_FILE="$NAME.service"
rm -f "$SVC_FILE"
cp "../config/user-apps/systemd.template" "$SVC_FILE"
sed -i "s+{user}+${APP_ACCOUNT}+g" "$SVC_FILE"
sed -i "s+{name}+${NAME}+g" "$SVC_FILE"
sed -i "s+{path}+${WD}+g" "$SVC_FILE"
sed -i "s+{bin}+${BIN}+g" "$SVC_FILE"

mv "$SVC_FILE" "$WD"

systemctl enable "$WD/$SVC_FILE"
systemctl start "$SVC_FILE"

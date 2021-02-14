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

"../deploy/user-application.sh" "../apps/hello-world" "/opt/apps/hello-world" true
"../deploy/systemd-service.sh" "hello-world" "/opt/apps/hello-world" "hello-world"
# You can allow the port externally for debugging if necessary
# "../deploy/allow-port.sh" 8080

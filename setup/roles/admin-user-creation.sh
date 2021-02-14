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

source ./variables
export $(cut -d= -f1 ./variables)

source "../setup/variables.sh"

"../setup/admin-user-creation.sh"

echo "admin-user-creation.sh completed successfully"

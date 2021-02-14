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

sudo -u $POSTGRES_USER \
    psql -v "ON_ERROR_STOP=1" --tuples-only -P format=unaligned -c \
        "SELECT datname \
        FROM pg_database \
        WHERE NOT datistemplate \
        AND datname <> 'postgres'" \
    | xargs -I % sh -c \
        "sudo -u $POSTGRES_USER pg_dump -C % > %.sql"

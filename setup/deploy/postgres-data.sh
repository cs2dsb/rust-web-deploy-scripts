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

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

function db_exists() {
    db=$1

    result=`sudo -u $POSTGRES_USER \
        psql --tuples-only -P format=unaligned -c \
            "SELECT datname \
            FROM pg_database \
            WHERE NOT datistemplate \
            AND datname = '$db'"`

    if [ "$result" == "$db" ]; then
        return
    fi

    false
}

# Create the roles first
while IFS="" read -r line || [ -n "$line" ]; do
    statement="\"
DO \\$\\$
BEGIN
    $line
    EXCEPTION WHEN DUPLICATE_OBJECT THEN
    RAISE NOTICE 'role already exists, skipping';
END
\\$\\$;\""

    sudo -u $POSTGRES_USER sh -c "printf \"%s\n\" $statement \
        | psql -v \"ON_ERROR_STOP=1\" --tuples-only -P format=unaligned"
done <<< `sed '/^$/d' "../config/postgres/roles.lst" | sed '/^#/d'` # seds remove comments and empty lines

# Then restore the databases
for f in ../config/postgres/*.sql; do
    [ -f "$f" ] || continue

    filename=$(basename -- "$f")
    db=${filename%.*}

    if db_exists $db; then
        echo "Database $db exists. Skipping $f"
    else
        sudo -u $POSTGRES_USER \
            psql -v "ON_ERROR_STOP=1" < "$f"
    fi
done

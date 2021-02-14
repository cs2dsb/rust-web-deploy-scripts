#!/usr/bin/env bash

#
# Backup a deployment folder to an archive
# Setup files are also included in the archive
#
# To use these backups, extract them onto the target machine
# and execute the setup/roles scripts (as root)
#
# Params:
#   $1 = new deployment name
#   $2 = true to delete the folder
#
# Will attempt to sudo install 7zip if it's missing
#

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

source "../setup/setup/apt-functions.sh"

sudo_apt_install 7z p7zip

NAME=${1:-}
DELETE=${2:-}

if [ "$NAME" = "" ]; then
    echo "backup-deployment requires 1 argument (name)" 1>&2
    exit 1
fi

if ! test -d "$NAME" >/dev/null 2>&1; then
    echo "\"$NAME\" not found" 1>&2
    exit 1
fi

rm -rf _backup
mkdir _backup

rsync -a --info=progress2 "../setup/" _backup
rsync -a --info=progress2 "$NAME" _backup

mkdir -p backups

ARCHIVE="./backups/`basename "$NAME"`.7z"
7z a  $ARCHIVE ./_backup/*
rm -rf _backup

if [ "$DELETE" == "true" ]; then
    rm -rf "$NAME"
fi

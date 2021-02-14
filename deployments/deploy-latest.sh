#!/usr/bin/env bash

# Sorts the directories in the current wd and deploys the
# last one. Designed to be used with YYYY-MM-DD named dirs.

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

ADDRESS=${1:-}
if [ "$ADDRESS" = "" ]; then
    echo "deploy-latest requires 1 argument (ssh address)" 1>&2
    exit 1
fi

LATEST=`ls -d -- */ | sort -r | head -n 1`

echo "Deploying \"$LATEST\" to $ADDRESS"
"${BASH_SOURCE%/*}/deploy.sh" $ADDRESS $LATEST

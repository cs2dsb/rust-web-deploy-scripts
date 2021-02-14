#!/usr/bin/env bash

#
# Create a new deployment folder
#
# Params:
#   $1 = new deployment name
#   $2 = optional base deployment to copy from
#
# A new blank deployment will regenerate dhparams.pem (which will take ages)
# one copying from a previous deployment won't.
#

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

NAME=${1:-}
BASE=${2:-}
BLANK=false

if [ "$NAME" = "" ]; then
    echo "new-deployment requires at least 1 argument (name, [base deployment])" 1>&2
    exit 1
fi

if [ "$BASE" = "" ]; then
    BASE="../setup"
    BLANK=true
fi

TARGET="${NAME}_`date "+%Y-%m-%d_%H-%M-%S"`"

BASE_PEM="$BASE/config/haproxy/dhparams.pem"
OUT_PEM="`pwd`/$TARGET/config/haproxy/dhparams.pem"
if [ "$BLANK" = true ] || ! test -f "$BASE_PEM"; then
    mkdir -p "$TARGET"
    cp -r "$BASE/config" "$TARGET/config"
    sudo sh -c "OUT_OVERRIDE=\"$OUT_PEM\" \"../setup/deploy/haproxy-generate-dhparams.sh\" && chown $USER:$USER \"$TARGET/config/haproxy/dhparams.pem\""
else
    cp -r "$BASE" "$TARGET"
fi

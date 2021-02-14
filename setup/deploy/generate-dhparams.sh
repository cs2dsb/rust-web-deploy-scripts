#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

OUT=${1:-}

if [ "$OUT" == "" ]; then
    echo "generate-dhparams requires 1 argument (output path)" 1>&2
    exit 1
fi

openssl dhparam -out dhparams.pem 4096
mv dhparams.pem "$OUT"

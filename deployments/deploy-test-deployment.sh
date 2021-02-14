#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

ADDRESS=${1:-}
if [ "$ADDRESS" = "" ]; then
    echo "deploy-test-deployment requires 1 argument (ssh address)" 1>&2
    exit 1
fi

cd "${BASH_SOURCE%/*}"
./deploy.sh $ADDRESS test_deployment

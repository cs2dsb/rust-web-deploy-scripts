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

mkdir -p "$HAPROXY_CERTS"

DEBUG=""
if [ "$ACMESH_DEBUG" == true ]; then
    DEBUG="--debug 3"
fi

while IFS="" read -r line || [ -n "$line" ]; do
    # Split the line by ,
    IFS=', ' read -r -a parts <<< "$line"

    # Extract the columns
    host=${parts[0]}

    # Issue the cert
    echo "Issuing cert for $host"
    set +o errexit
    "$ACMESH_BIN" $ACME_TEST --issue --standalone --httpport 8888 -d $host $DEBUG
    ACME_CODE=$?
    set -o errexit

    # 0 = Ok, 2 = exists and not due for renewal
    if [ $ACME_CODE != 0 ] && [ $ACME_CODE != 2 ]; then
        echo "acme.sh issue failed with error code $ACME_CODE" 1>&2
        exit 1
    fi

    echo "Deploying cert for $host"
    # Deploy the new cert (this config is also saved by acme.sh for renewals)
    DEPLOY_HAPROXY_PEM_PATH="$HAPROXY_CERTS" DEPLOY_HAPROXY_RELOAD="/usr/sbin/service haproxy restart" \
    "$ACMESH_BIN" -d $host --deploy --deploy-hook haproxy $DEBUG

    # Because we are restarting the service on each deploy systemd can failed and return an error
    # this clears the fail counter to prevent that
    systemctl reset-failed haproxy.service

done <<< `sed '/^$/d' "../config/haproxy/sites.lst" | sed '/^#/d'` # seds remove comments and empty lines

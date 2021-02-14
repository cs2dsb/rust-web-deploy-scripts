#!/usr/bin/env bash

#
# Params:
#   $1 = server dns/ip address
#   $2 = deployment name
#   $3 = optional user to connect with
#

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

ADDRESS=${1:-}
DEPLOYMENT=${2:-}
USERNAME=${3:-}

if [ "$ADDRESS" = "" ] || [ "$DEPLOYMENT" == "" ]; then
    echo "deploy requires at least 2 arguments (address, deployment name, [user])" 1>&2
    exit 1
fi

if [ "$USERNAME" = "" ]; then
    USERNAME=$USER
fi

rsync -a --info=progress2 "${BASH_SOURCE%/*}/../setup/" $USERNAME@$ADDRESS:/home/$USER/deployment
rsync -aL --info=progress2 "${BASH_SOURCE%/*}/../utils" $USERNAME@$ADDRESS:/home/$USER/deployment
rsync -a --info=progress2 $DEPLOYMENT/ $USERNAME@$ADDRESS:/home/$USER/deployment

ssh $USERNAME@$ADDRESS "sudo -i sh -c \"cd /home/$USERNAME/deployment/roles; ./dogsbody.sh\""

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
source "./apt-functions.sh"

if [ "$XTRACE" = true ]; then
    # Print every command for debugging
    set -o xtrace
fi

if [ "$USER_PUB_KEY" == "" ] || [ "$USER_ACCOUNT" == "" ]; then
    echo "USER_PUB_KEY and USER_ACCOUNT are mandatory for admin-user-creation to work" 1>&2
    exit 1
fi

# Create the user and add to sudo group
if ! id "${USER_ACCOUNT}" &>/dev/null; then
    adduser --disabled-password ${USER_ACCOUNT} &>/dev/null
    usermod -aG sudo ${USER_ACCOUNT}

    # Allow NOPASSWD
    echo "${USER_ACCOUNT}   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
fi

# Create authorized_keys
SSH_DIR="/home/${USER_ACCOUNT}/.ssh"
AUTHORIZED_KEYS=${SSH_DIR}/authorized_keys
mkdir -p ${SSH_DIR}
if ! grep -q "${USER_PUB_KEY}" $AUTHORIZED_KEYS &>/dev/null; then
    echo "${USER_PUB_KEY}" >> $AUTHORIZED_KEYS
fi

# Make sure the ownership is right
chown -R ${USER_ACCOUNT}:${USER_ACCOUNT} ${SSH_DIR}
chmod 700 ${SSH_DIR}
chmod 600 ${AUTHORIZED_KEYS}

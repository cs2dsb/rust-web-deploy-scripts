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

# Disable protocol 1
sed -i -e 's/^.*Protocol.*$/Protocol 2/' $SSHD_CONFIG

# Disable root login
sed -i -e 's/^.*PermitRootLogin.*$/PermitRootLogin no/' $SSHD_CONFIG

# Change max auth attempts to 2
sed -i -e "s/^.*MaxAuthTries.*$/MaxAuthTries 2/" $SSHD_CONFIG

# Disable empty passwords
sed -i -e 's/^.*PermitEmptyPasswords.*$/PermitEmptyPasswords no/' $SSHD_CONFIG

# Change login grace time to 5 seconds
sed -i -e "s/^.*LoginGraceTime.*$/LoginGraceTime 5/" $SSHD_CONFIG

# Disable password auth
sed -i -e 's/^.*PasswordAuthenticat.*$/PasswordAuthentication no/g' $SSHD_CONFIG

# Disable rhosts
sed -i -e 's/^.*IgnoreRhosts.*$/IgnoreRhosts yes/' $SSHD_CONFIG

# Disable X11 forwarding
sed -i -e 's/^.*X11Forwarding.*$/X11Forwarding no/' $SSHD_CONFIG

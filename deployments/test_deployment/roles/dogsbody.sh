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

source ./variables
export $(cut -d= -f1 ./variables)

source "../setup/variables.sh"

# Core: common utils, firewall, user creation, ssh, wireguard
"../setup/base.sh"
"../setup/firewall.sh"
"../setup/admin-user-creation.sh"
"../setup/app-user-creation.sh"
"../setup/ssh-hardening.sh"
"../setup/wireguard.sh"

# Web proxy: haproxy, acme client for ssl
"../setup/haproxy.sh"
"../setup/acme-sh.sh"

# Configure proxied sites: request ssl certs, configure proxy frontends & backends
# acme needs to be configured first otherwise the haproxy config will try to load non-existent certs and error
"../deploy/acme-sh-sites.sh"
"../deploy/haproxy-global.sh"

# Database: postgres, data restoration
"../setup/postgres.sh"
"../deploy/postgres-data.sh"

# Programming languages
"../setup/golang.sh"
"../setup/rust.sh"

# Diesel cli tool used by some user application setups
"../setup/diesel.sh"

# User applications: install bins, configure systemd services
"../apps/user-apps.sh"

# Hostname has to be last because lots of network things break once the hosts file is changed
# It also reboots the machine if the hostname was changed
"../setup/hostname.sh" "covvee-`date "+%Y%m%d%H"`"

echo "dogsbody.sh completed successfully"

#!/usr/bin/env bash

# If true, enable xtrace to print every command
XTRACE="${XTRACE:-false}"

# If true, acme.sh commands will have --debug 3 added
ACMESH_DEBUG="${ACMESH_DEBUG:-false}"

# If true, wireguard will be installed and configured to be the only way of connecting to the new machine
USE_WIREGUARD="${USE_WIREGUARD:-true}"

WIREGUARD_PORT="${WIREGUARD_PORT:-51820}"

WIREGUARD_CONF="${WIREGUARD_CONF:-/etc/wireguard/wg0.conf}"

# For adding any installed binaries to root + user paths
GLOBAL_PROFILE="${GLOBAL_PROFILE:-/etc/profile}"

# Path to list.d folder for adding apt repos to
LIST_D="${LIST_D:-/etc/apt/sources.list.d}"

# Path to sshd_config
SSHD_CONFIG="${SSHD_CONFIG:-/etc/ssh/sshd_config}"

# Base folder of acme.sh install
ACMESH_HOME="${ACMESH_HOME:-/root/.acme.sh}"

# The acme bin (this is used via absolute path because acme.sh adds an alias for itself instead of modifying the path)
ACMESH_BIN="${ACMESH_BIN:-$ACMESH_HOME/acme.sh}"

# HAProxy base folder
HAPROXY_BASE="${HAPROXY_BASE:-/etc/haproxy}"

# HAProxy certs folder
HAPROXY_CERTS="${HAPROXY_CERTS:-${HAPROXY_BASE}/certs}"

# HAProxy main config file
HAPROXY_CONFIG="${HAPROXY_CONFIG:-${HAPROXY_BASE}/haproxy.cfg}"

# HAProxy diffie helman params key file
HAPROXY_DHPARAMS="${HAPROXY_DHPARAMS:-${HAPROXY_BASE}/dhparams.pem}"

# User account for admin
USER_ACCOUNT="${USER_ACCOUNT:-${USER_ACCOUNT:-admin}}"

# User pub key added to authorized_keys for new user
USER_PUB_KEY="${USER_PUB_KEY:-}"

# Rust version to install
RUST_VERSION="${RUST_VERSION:-1.49.0}"
RUST_TARGET="${RUST_TARGET:-x86_64-unknown-linux-gnu}"

# Postgres version
POSTGRES_VERSION="${POSTGRES_VERSION:-12}"

# Currently only used for creating and backing up databases, changing this
# WON'T change the user created by postgres during install
POSTGRES_USER="${POSTGRES_USER:-postgres}"

# HAProxy version (".*" is appended to the end of whatever is specified here)
HAPROXY_VERSION="${HAPROXY_VERSION:-2.0}"

# The port acme.sh will listen to
ACME_PORT="${ACME_PORT:-8888}"

# Set this to "--test" to issue test certs, blank or unset to issue live certs
ACME_TEST="${ACME_TEST:---test}"

# The account user applications are run as (by default)
APP_ACCOUNT="${APP_ACCOUNT:-web-apps}"

#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

# Allow incoming traffic on the provided port
firewall_allow_port() {
    port=${1:-}

    if [ "$port" = "" ]; then
        echo "firewall_allow_port() requires at 1 argument (port)" 1>&2
        exit 1
    fi

    if command -v ufw >/dev/null 2>&1; then
        echo "Allowing incoming traffic on port $port"

        ufw allow $port
    fi
}

# Allow incoming traffic from the specified origin
firewall_allow_from() {
    origin=${1:-}

    if [ "$origin" = "" ]; then
        echo "firewall_allow_subnet() requires at 1 argument (origin)" 1>&2
        exit 1
    fi

    if command -v ufw >/dev/null 2>&1; then
        echo "Allowing incoming traffic from $origin"

        ufw allow from $origin
    fi
}

# Remove an existing allow rule
firewall_remove_allow_port() {
    port=${1:-}

    if [ "$port" = "" ]; then
        echo "firewall_remove_allow_port() requires at 1 argument (port)" 1>&2
        exit 1
    fi

    if command -v ufw >/dev/null 2>&1; then
        echo "Allowing incoming traffic on port $port"

        echo "y" | ufw delete allow $port
    fi
}

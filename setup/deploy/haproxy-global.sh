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

mkdir -p $HAPROXY_CERTS

function copy_if_missing() {
    source=$1
    target=$2

    if ! test -f $target >/dev/null 2>&1; then
        cp $source $target
    fi
}

copy_if_missing "../config/haproxy/dhparams.pem" "$HAPROXY_DHPARAMS"
copy_if_missing "../config/haproxy/extension_blacklist.lst" "${HAPROXY_BASE}/extension_blacklist.lst"
copy_if_missing "../config/haproxy/extension_whitelist.lst" "${HAPROXY_BASE}/extension_whitelist.lst"
copy_if_missing "../config/haproxy/redirect_host.map" "${HAPROXY_BASE}/redirect_host.map"
copy_if_missing "../config/haproxy/redirect_host_path.map" "${HAPROXY_BASE}/redirect_host_path.map"
copy_if_missing "../config/haproxy/haproxy.cfg.template" "${HAPROXY_BASE}/haproxy.cfg.template"

# Skip if config already exists
if test -f "$HAPROXY_CONFIG" >/dev/null 2>&1; then
    # Could be the ACME_ONLY stub config, check for that
    if ! grep -q "# ACME_ONLY" "$HAPROXY_CONFIG" &>/dev/null; then
        exit 0
    else
        rm -f "$HAPROXY_CONFIG"
    fi
fi

# If the cfg doesn't exist, generate it from the template
marker="#TEMPLATE_"
while IFS="" read -r line || [ -n "$line" ]; do
    # Trim leading whitespace
    trimmed="${line#"${line%%[![:space:]]*}"}"

    # If it's not a template line just spit out the line and move on
    if [[ $trimmed != $marker* ]]; then
        printf '%s\n' "$line" >> $HAPROXY_CONFIG
        continue
    fi

    # Grab what was trimmed to maintain indentation
    spaces=${line%"$trimmed"}

    # Chop off the marker
    template="${trimmed:$((${#marker} + 1)):${#trimmed}}"

    while IFS="" read -r line || [ -n "$line" ]; do
        # Split the line by ,
        IFS=', ' read -r -a parts <<< "$line"

        # Extract the columns
        host=${parts[0]}
        ip=${parts[1]}
        port=${parts[2]}

        # Create a backend name from the host
        backend="`echo $host | tr . _`_backend"

        # Use eval to expand the variable in the template line
        # The -e allows the template to contain "\n" which is then expanded in the final config
        resolved=`eval echo -e "\"$template\""`

        # Spit out the new line including the space before the template
        printf '%s%s\n' "$spaces" "$resolved" >> $HAPROXY_CONFIG

    done <<< `sed '/^$/d' "../config/haproxy/sites.lst" | sed '/^#/d'` # seds remove comments and empty lines
done < "../config/haproxy/haproxy.cfg.template"

cat /etc/haproxy/haproxy.cfg

# Test the config so the deploy will fail if it's invalid
haproxy -c -f $HAPROXY_CONFIG

# Restart the service to make the config active
systemctl restart haproxy.service

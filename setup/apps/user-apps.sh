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

# Suggested usage is to create a folder under here containing the delivery artifacts for
# a given app.
#
# user-application.sh copies the files over if the target doesn't exist, checks
# the app user account exists and changes permissions on the target to match that user.
# If there is a file called post-install.sh in the app folder it is run after the files
# are copied over and the permissions are fixed.
#
# systemd-service.sh creates a simple systemd service from the template in the config dir
# by replacing the app name, working directory and bin name. It copies the resulting
# service file into the apps working directory, registers it and starts it. Does nothing
# if the service is already registered.
#
# allow-port.sh allows incoming traffic on a given port
#
# Example:
# "../deploy/user-application.sh" "./example-app/" "/opt/apps/example-app" true
# "../deploy/systemd-service.sh" "example-app" "/opt/apps/example-app" "my_bin"
# "../deploy/allow-port.sh" 1717

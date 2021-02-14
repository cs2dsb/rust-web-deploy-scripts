#!/usr/bin/env bash

#
# Create a new deployment repository, adding the deploy-scripts as a submodule
# and creating a skeleton deployment folder. Should be run outside of any other
# git repositories and will create a new git repo in the folder specified by $1
#
# Params:
#   $1 = name of the new deployment repository
#

DEPLOY_SCRIPTS="https://github.com/cs2dsb/rust-web-deploy-scripts.git"

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail

NAME=${1:-}

# Check the name isn't empty
if [ "$NAME" = "" ]; then
    echo "new-deployment-repository requires 1 argument (name)" 1>&2
    exit 1
fi

# Check we aren't inside a git repo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This shouldn't be run inside an existing git repo" 1>&2
    exit 1
fi

# Check the name isn't an existing file/dir
if test -f "$NAME" || test -d "$NAME"; then
    echo "$NAME already exists" 1>&2
    exit 1
fi

echo "Creating deployment repo $NAME"

TS=`date "+%Y-%m-%d_%H-%M-%S"`

mkdir -p "$NAME"

cd "$NAME"

echo "Initializing git repo"
git init

echo "Adding deploy-scripts submodule"
git submodule add "$DEPLOY_SCRIPTS" deploy-scripts
#ln -s ../deploy-scripts deploy-scripts

echo "Creating skeleton deployment"
mkdir -p "deployments/$TS/config/wireguard"
mkdir -p "deployments/$TS/config/haproxy"
mkdir -p "deployments/$TS/apps"
mkdir -p "deployments/$TS/roles"
cp ./deploy-scripts/setup/config/haproxy/sites.lst deployments/$TS/config/haproxy/
cp ./deploy-scripts/setup/apps/user-apps.sh deployments/$TS/apps/
cp ./deploy-scripts/setup/roles/variables deployments/$TS/roles/

echo "Creating helper scripts"
echo "#!/usr/bin/env bash" > deploy-latest.sh
echo "cd deployments" >> deploy-latest.sh
echo '../deploy-scripts/deployments/deploy-latest.sh "$@"' >> deploy-latest.sh
chmod +x deploy-latest.sh

echo "Generating wireguard keys"
./deploy-scripts/utils/create-wireguard-keys.sh "deployments/$TS"

echo "Generating dhparams"
./deploy-scripts/setup/deploy/generate-dhparams.sh "deployments/$TS/config/haproxy/dhparams.pem"

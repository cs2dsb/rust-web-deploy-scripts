#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail


DEPLOYMENT=${1:-}

# Check the deployment provided isn't empty
if [ "$DEPLOYMENT" = "" ] || ! test -d "$DEPLOYMENT" ; then
    echo "vagrant-recreate-and-deploy requires 1 argument (DEPLOYMENT)" 1>&2
    exit 1
fi

vagrant destroy -f
vagrant up --provider=virtualbox

# This finds the route to the NAT adapter network and deletes it so the above bridge adapter works correctly
vagrant ssh -c 'ip route | grep -oP "10.0\..*/24" | xargs -I{} sudo ip route del {}'
vagrant ssh -c 'ip route | grep -oP "default via 10.0\.[^ ]*" | cut -d" " -f3 | xargs -I{} sudo ip route del default via {}'
vagrant ssh -c 'sudo rm /etc/netplan/50-cloud-init.yaml'

ADDRESS=`vagrant ssh -c "hostname -I" | cut -d' ' -f2`

if test -f ~/.ssh/known_hosts >/dev/null 2>&1; then
    until ssh-keygen -f ~/.ssh/known_hosts -R $ADDRESS 2>&1 | grep "not found"; do
        echo "More than one?"
    done
    until ssh-keygen -H -f ~/.ssh/known_hosts -R $ADDRESS 2>&1 | grep "not found"; do
        echo "More than one?"
    done
fi
ssh -o StrictHostKeyChecking=accept-new $ADDRESS exit

vagrant halt
VBoxManage modifyvm vagrant-deployment-test --nic1 none
VBoxManage startvm vagrant-deployment-test --type headless

while ! ssh $ADDRESS exit &>/dev/null
do
    echo "Trying again..."
    sleep 5
done

deployments/deploy.sh $ADDRESS "$DEPLOYMENT"

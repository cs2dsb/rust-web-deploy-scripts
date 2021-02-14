# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |v|
    v.name = "vagrant-deployment-test"
  end

  config.vm.box = "ubuntu/focal64"

  # If you want to locally test letsencrypt certs, uncomment this, update the "bridge" value
  # to the local network adapter and configure port forwarding for 80 and 443 on the router.
  # You may also need to stop the VM and disable the NAT network vagrant always creates
  # as it sometimes interferes with the public network working properly.
  config.vm.network "public_network" , :mac => "080027b31cee", bridge: "enp34s0"

  config.vm.provision "file", source: "setup", destination: "deployment"
  config.vm.provision "file", source: "deployments/test_deployment", destination: "deployment"
  config.vm.provision "shell", inline: "deployment/roles/admin-user-creation.sh"
  config.vm.provision "shell", inline: "rm -rf deployment"

end

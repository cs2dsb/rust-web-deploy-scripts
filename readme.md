# Deployment scripts

Scripts primarily for deploying rust web apps behind a haproxy reverse proxy with certs from Let's Encrypt.

These scripts are currently designed to be run once at commissioning time - they won't necessarily update a target machine if changes have been made between deployments. The scripts can be run multiple times without breaking but they won't overwrite existing config files. If you want to modify something after it's been setup you'll have to check the relevant script for the check it makes to see if it needs to do anything and (usually) delete the config file on the target machine. Updating existing installs is a TODO but for the most part I prefer spinning up a new machine and changing the network over once it's up and tested.

## Getting started

### Making a deployment repo/project

* Make a new repositiory for containing your deployment
  * Change to the directory you want to contain the new deployment repo (not including the new repo dir)
  * Run `deployments/new-deployment-repo.sh`
    * Fetched the script: `wget -O new-deployment-repository.sh https://raw.githubusercontent.com/cs2dsb/rust-web-deploy-scripts/main/deployments/new-deployment-repository.sh`
    * Make it executable `chmod +x ./new-deployment-repository.sh`
    * Run it with the new deployment/project name `./new-deployment-repository.sh my-amazing-project-deployment`
    * It will:
      * create the dir under the current directory
      * initialize a git repo there
      * create a skeleton deployment for the current date
      * create new wireguard keys
      * create a new dhparams.pem
* Update user details in `deployments/<date>/roles/variables` to reflect the user account and public ssh key you want to use to deploy to the target machine
* Add the list of sites you want to serve in `deployments/<date>/config/haproxy/sites.lst`
* Add user-apps
  * Add a folder for each app under `deployments/<date>/apps`
  * Add the deployment steps for each app to `deployments/<date>/user-apps.sh`
* If using postgres databases
  * Add roles you need to `deployments/<date>/config/postgres/roles.lst`
  * Create `<database name>.sql` files in `deployments/<date>/config/postgres` for each database you want to deploy. See `dump-all-pg-databases.sh` for a method of migrating databases

### Testing locally with vagrant

* To test Let's Encrypt certificate functions
  * Add sites sites you want to test to `deployments/<date>/config/haproxy/sites.lst`
  * Map ports 80 and 443 to the public adapter vagrant creates. The mac address for this can be found in `Vagrantfile`
* Run `vagrant-recreate-and-deploy-test.sh` providing the path to the deployment folder you want to test (e.g. `deployments/<date>` in your deployment repo/project)
  * Note: this only works with VirtualBox as the provider due to the extra network steps the script performs. Check out what the script is doing and recreate this with another provider
  * This will destroy the existing vagrant vm if there is one
  * Create a new VM
  * Grab the IP address using `vagrant ssh`
  * Delete the NAT adapter config on the VM
  * Shut the VM down
  * Disable the NAT adapter using VBoxManage
  * Start the machine
  * Delete any entries in `~/.ssh/known_hosts` for the VM IP
  * Connect via SSH and accept the host key
  * Run `deployments/deploy.sh` passing $1 as the deployment and the IP address as the address

### Customizing your deployment

Any file from `setup` can be copied into your deployment and customised as you see fit. `deploy.sh` uses rsync to copy `setup` first then overwrites it with your deployment folder.

#### Disabling steps

This can be useful to skip slow tasks that you don't need (e.g. the rust dev chain and diesel_cli parts take a long time to install and compile on a slow VPS)

* Copy `setup/roles/dogsbody.sh` into your deployment
* Edit it, deleting or commenting out the steps you don't need

#### Variables

A full list of variables used in the scripts can be found in `setup/setup/variables.sh`. This script will only set the value of a variable if it wasn't previously set - this provides a facility for the deployment to set a few variables without having to provide the whole `variables.sh` file.

Variables can be set as simple VARIABLE=value statements in `roles/variables` and will be loaded and exported as part of the role script (dogsbody.sh).

##### Putting it LIVE

By default the Let's Encrypt staging area is used which has extemely high limits and issues untrusted certs for dev purposes.

To switch over to issuing live certs add ACME_TEST=false to `roles/variables`.

It's strongly recommended you do at least one full deployment using the staging server and non-live domains (`deploy-test.<domain>` perhaps?) to make sure everything works before you start using the live servers which have some fairly tight limits you don't want to run afoul of.

##### Live migrations

The main issue with live migrations with these scripts is the Let's Encrypt cert config - during deployment the scripts expect domain renewals to work but of course this means having requests coming to this new box prior to it being set up.

The solution I've been using is to manual update the haproxy config on the old machine to direct only acme requests to the new VM before running the deploy scripts on it.

To do this in haproxy you simply need to update the `backend acme_http` section to point to the new servers IP and port 80.

So long as the live SSL certs aren't due to expire during the migration there should be no issue with this approach (as far as I can see... raise an issue to discuss if you see any problems). You can use `check-cert-expiry.sh` to quickly see how long is left on a cert for a given domain.

## Organization

This repo is designed to be used as a sub-module of the repo containing the final deployment. The scripts that copy the files onto the target machine copy the `setup` directory tree to the host first then overwrite it with the contents of the specific deployment. This way you can override any part of the setup procedure if necessary.

### deployments

* `test_deployment` - an example deployment containing a Hello World app in actix-web. The only thing that will need to be changed is the domain in `haproxy/sites.lst` to one that points to your test machine. `vagrant-recreate-and-deploy-test.sh` can be used to create a new vagrant vm and deploy this test deployment to it so long as the mac address from Vagrantfile is configured to receive por 80 and 443 traffic.

* `backup_deployment.sh` - maintenance script that will create a 7z archive of the setup folder and a provided deployment folder then optionally delete the original. This will create a snapshot of all the setup scripts and deployment specific files at this instant so the deployment can be recreated regardless of the current state of the setup scripts.

* `deploy-test-deployment.sh` - example wrapper around `deploy.sh` that deploys the test_deployment to a target machine.

* `deploy.sh` - rsyncs setup, utils and the provided deployment to a given address then runs the dogsbody role on the target machine.

* `new-deployment.sh` - creates a new skeleton deployment optionally from a previous deployment. If there is no previous deployment or if the previous deployment doesn't contain a `dhparams.pem` file, one is created.

* `setup-local-wireguard.sh` - creates a new client connection on the local machine from the wireguard config and keys from a provided deployment. Wireguard connection name will be incremented with each run so old connections won't be overwritten. Repeated runs of this for the same config may result in invalid duplicate config file - in this case check /etc/wireguard and remove any you no longer need.

### setup
#### apps

* `user-apps.sh` - User application binary deployment is configured here

#### config

Configuration files, templates and other deployment artifacts

* haproxy

    * `dhparams.pem` - pregenerated diffie-hellman parameters. This should either be overwritten in the deployment or regenerated using `haproxy-generate-dhparams.sh` during setup (it's extremely slow on a vps so suggest generate it and store it in the deployment).

    * `extension_blacklist.lst` - a list of extensions that will cause the connection to be silently dropped. Common suffixes probed by attackers can be put in here, or it can be cleared out if you don't want this kind of defence.

    * `extension_whitelist.lst` - this is a list of extensions that will never be flagged as abuse - white listing images and common static files is probably sensible, especially if the site offers any kind of CMS or user profile customisation.

    * `haproxy-acme-only.cfg` - this is an initial config that exposes just the paths used by Let's Encrypt to issue SSL certs. The reason there are two is because the 2nd (real) config tries to load certificates from the cert folder and haproxy won't start if this folder is empty.

    * `haproxy.cfg.template` - template for the real haproxy config file. "#TEMPLATE_" lines are copied once for each site defined in `sites.lst` with the $host, $ip and $port values replaced. See `haproxy-global.sh` for details of how it works.

    * `redirect_host.map` - map file for redirecting based off just the host part of the URL. Primarily used for mapping apex domains (`example.com`) to www (`www.example.com`) or vice versa. Can also be used to redirect incorrect spellings, deprecated sites and extra landing pages.

    * `redirect_host_path.map` - map file for redirecting based off the whole URL including host and path. Useful if you need to change a bunch of URLs when you change CMS or similar. Applied AFTER `redirect_host.map` so duplicate entries for apex+www shouldn't be necessary here.

    * `sites.lst` - a list of sites that you want to serve from haproxy and request SSL certificates for. Contains `host`, `ip` and `port`. Host is the domain (`example.com`), ip and port are the network address of the backend server. For running multiple sites on one box the address will be 127.0.0.1 and the ports unique for each site. See `haproxy-global.sh` and `acme-sh-sites.sh` for how this file is used.

* postgres

    * `*.sql` - sql files used to create the postgres databases. Typically created by pg_dump with the -C option. The name of the file will be used to check if the database already exists so they must be named `<database name>.sql`.

    * `roles.lst` - list of users/roles to create. These are created before attempting to execute the sql files.

* user-apps

    * `systemd.template` - simple template for a systemd service. Check `systemd-service.sh` for how this template is used.

* wireguard

    * `wg0-client-conf.template` - the wireguard template for the client side of the wireguard connection. Not used on the deployment target. Used by `setup-local-wireguard.sh`. The default configuration is a 1:1 client to server setup. You'll have to customize both client and server configurations to do something more sophisticated.

    * `wg0-server-conf.template` - the wireguard template for the server side of the wireguard connection.

#### deploy

   * `acme-sh-sites.sh` - requests certificates from Let's Encrypt for each domain defined in `sites.lst` and, assuming they are issued, configures acme.sh to deploy these certs to the haproxy cert folder. `ACME_TEST` variable in `variables.sh` determines if the staging or live servers are used.

   * `allow-port.sh` - allows a port through the firewall (not currently used).

   * `haproxy-generate-dhparams.sh` - wrapper around `generate-dhparams.sh` designed to be run as part of a deployment on the target machine. Generation can take 20+ minutes on a low spec VPS so it's suggested to generate one locally prior to deploying. `new-deployment.sh` will do this automatically if there is `dhparams.pem` in the base deployment (see `new-deployment.sh`for more details).

   * `generate-dhparams.sh` - uses openssl to generate a new `dhparams.pem` file and moves it to the path provided.

   * `haproxy-global.sh` - uses `haproxy.cfg.template` and `sites.lst` to create and install the haproxy config (see those files above for more info).

   * `postgres-data.sh` - creates users/roles defined in `roles.lst` then creates databases for each `<database name>.sql` if the database doesn't already exist.

   * `systemd-service.sh` - uses `system.template` to create a systemd service file for each user app. Replaces the service name, working directory, bin and user account then moves the service file to the app working directory before installing and starting the service.

   * `user-application.sh` - rsyncs the contents of a user application directory to a specified install location (I've been using /opt/apps/{app}), sets the ownership of the target location to the APP_ACCOUNT (defined in `variables.sh`) and runs `post-install.sh` if one exists in the app directory. Optionally overwrites the target location.

#### roles

  * `admin-user-creation.sh` - calls `setup/admin-user-creation.sh` after exporting the credentials from `variables`. Used mainly for local testing with vagrant. Usually setting up the admin user account and public key access will be done during first boot of the vm or via a web console. Could also be used if you are given root user ssh access.

  * `dogsbody.sh` - sets up everything these scripts can do. Starting place for deployments that don't need all the parts. See comments in the file for what each part does.

  * `variables` - minimum variables that need to be exported prior to creating the admin user account & configuring their SSH access.

#### setup

  * `acme-sh.sh` - downloads the latest release from acmesh-offical repo and installs it under the root user.

  * `admin-user-creation.sh` - creates the admin user USER_ACCOUNT with authorized ssh key USER_PUB_KEY.

  * `app-user-creation.sh` - creates a service account for running user applications.

  * `apt-functions.sh` - apt functions used for checking and installing dependencies.

  * `base.sh` - installs some standard tools that other scripts (or the admin user) need.

  * `cargo-install-bin.sh` - uses `cargo install` to install rust tools. See diesel.sh for example.

  * `diesel.sh` - installs the diesel ORM cli tool for managing diesel migrations and various other admin functions.

  * `firewall-functions.sh` - functions to add and remove firewall exceptions.

  * `firewall.sh` - installs and configures firewall. Changes default incoming to deny and outgoing to allow. Adds allow rule for SSH if wireguard is not in use.

  * `golang.sh` - downloads the latest stable golang release and installs it under /usr/local/go.

  * `haproxy.sh` - adds the official haproxy ppa and installs haproxy. If haproxy wasn't previously installed it also overwrites the default config with `haproxy-acme-only.cfg`

  * `hostname.sh` - changes the machines hostname, updates /etc/hosts and reboots. Does nothing if the hostname is unchanged. This must be run last because many things break if you change the hostname and don't reboot.

  * `postgres.sh` - adds the official apt repo for postgres and installs postgres.

  * `rust.sh` - downloads and installs the version of rust specified by RUST_VERSION and RUST_TARGET.

  * `ssh-hardening.sh` - various common ssh hardening config changes.

  * `variables.sh` - variables used by many of the scripts. They are only set if the variable was previously unset - this makes it possible to set them in the role script or other wrapper script.

  * `wireguard.sh` - installs wireguard and generates config files. Requires `server_private_key` and `client_public_key` be present in the config/wireguard directory. See `create-wireguard-keys.sh` to create these.

### utils

   * `check-haproxy-abuse-stick-table.sh` - prints out the current contents of the haproxy abuse stick table.

   * `check-haproxy-config.sh` - checks that provided haproxy config file is valid.

   * `clear-haproxy-abuse-stick-table.sh` - clears the haproxy abuse stick table.

   * `create-wireguard-keys.sh` - creates wireguard keys in the provided deployment folder if they don't already exist.

   * `dump-all-pg-databases.sh` - selects all non-system, non-template databases on the current system and dumps creation scripts for them using pg_dump. To be used on old server to migrate to new install. Output of this command can be directly placed in `config/postgres` ready for deployment. You'll have to handle `roles.lst` manually for now.

  * `variables.sh` - symlink to the main `variables.sh`.

## Things of note

### haproxy abuse handling

The default haproxy configuration template has aggressive banning of abusive users. Abuse requests will be silently dropped - that is, the kernel will forget about the connection but won't tell the other side it has been closed.

There are two mechanisms in place

* `extension_blacklist.lst` - all requests to any URLs ending in these suffixes will be dropped. This is commonly populated with known attack URLs and technologies not used on this site (e.g. .php). These do not get recorded against the client as an abuse request for ongoing banning purposes.

* `abuse_stick_table` - a haproxy stick table is used to keep track of the number of failed HTTP requests for a given client in the last 30 minutes. If this number exceeds 10, all requests from that client will be dropped until their entry in the stick table expires. `extension_whitelist.lst` contains a list of suffixes that won't count towards the error count - it probably makes sense to allow 404s on images/js/css/etc. as these are more likely to just be dev errors. `check-haproxy-abuse-stick-table.sh` and `clear-haproxy-abuse-stick-table.sh` can be used to monitor and clear the stick table on the server.

### wireguard 1:1

The wireguard config has only been written with 1 client connecting to 1 server in mind.

It is a low priority TODO item to make it possible to set up clusters of clients & servers all on the same virtual network.

For now, each deployment can have it's own wireguard subnet manually configured in it's wireguard config template files.

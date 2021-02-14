#!/usr/bin/env bash

# Exit when any command fails
set -o errexit

# Exit when an undeclared variable is used
set -o nounset

# Exit when a piped command returns a non-zero exit code
set -o pipefail


# Make sure we only do apt update once and only if necessary
APT_UPDATED=false
apt_update() {
    if [ "$APT_UPDATED" = false ]; then
        APT_UPDATED=true
        apt-get -qq update
    fi
}
sudo_apt_update() {
    if [ "$APT_UPDATED" = false ]; then
        APT_UPDATED=true
        sudo apt-get -qq update
    fi
}

# Check if bin is installed and if not, install it
apt_install() {
    bin=${1:-}
    package=${2:-}

    if [ "$bin" = "" ]; then
        echo "apt_install() requires at least 1 argument (bin, [package])" 1>&2
        exit 1
    fi

    if [ "$package" = "" ]; then
        package=$bin
    fi

    if ! command -v $1 >/dev/null 2>&1; then
        echo "Installing package $package ($bin)."

        # Update if necessary
        apt_update

        apt-get -qq install -y $package
    fi
}

# Check if bin is installed and if not, install it. Uses sudo
sudo_apt_install() {
    bin=${1:-}
    package=${2:-}

    if [ "$bin" = "" ]; then
        echo "apt_install() requires at least 1 argument (bin, [package])" 1>&2
        exit 1
    fi

    if [ "$package" = "" ]; then
        package=$bin
    fi

    if ! command -v $1 >/dev/null 2>&1; then
        echo "Installing package $package ($bin)."

        # Update if necessary
        sudo_apt_update

        sudo apt-get -qq install -y $package
    fi
}

# Check if lib is installed and if not, install it
apt_lib_install() {
    lib=${1:-}
    package=${2:-}

    if [ "$lib" = "" ]; then
        echo "apt_lib_install() requires at least 1 argument (lib, [package])" 1>&2
        exit 1
    fi

    if [ "$package" = "" ]; then
        package=$lib
    fi

    if ! dpkg -s "$lib" >/dev/null 2>&1; then
        echo "Installing package $package ($lib)."

        # Update if necessary
        sudo_apt_update

        apt-get -qq install -y $package
    fi
}

# Check if bin is installed and if so, purge it
apt_purge() {
    bin=${1:-}
    package=${2:-}

    if [ "$bin" = "" ]; then
        echo "apt_purge() requires at least 1 argument (bin, [package])" 1>&2
        exit 1
    fi

    if [ "$package" = "" ]; then
        package=$bin
    fi

    if command -v $1 >/dev/null 2>&1; then
        echo "Purging package $package ($bin)."

        apt-get -qq remove --purge $package
    fi
}

# Check if ppa exists and add it if not
add_ppa() {
    ppa=${1:-}

    if [ "$ppa" = "" ]; then
        echo "add_ppa() requires 1 argument (ppa)" 1>&2
        exit 1
    fi

    if ! grep -q "^deb .*$ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
        add-apt-repository --yes --update ppa:$ppa
    fi
}

# Install a package from a ppa
apt_install_ppa() {
    # Make sure add-apt-repository is installed
    apt_install add-apt-repository software-properties-common

    bin=${1:-}
    ppa=${2:-}
    package=${3:-}

    if [ "$bin" = "" ] || [ "$ppa" = "" ]; then
        echo "apt_install_ppa() requires at least 2 arguments (bin, ppa, [package])" 1>&2
    fi

    if [ "$package" = "" ]; then
        package=$bin
    fi

    if ! command -v $1 >/dev/null 2>&1; then
        echo "Installing package $package ($bin) from $ppa."

        add_ppa "$ppa"
        apt_install $bin $package
    fi
}

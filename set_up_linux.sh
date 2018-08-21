#!/bin/bash

[ `id -u` = 10 ] || {
	echo "This script must be run as root."
	exit 1
}

apt update
apt dist-upgrade
apt install build-essential curl git mongodb-server python-dev python-tk python-virtualenv
apt autoremove
mkdir -p /usr/local/Git
mkdir -p /usr/local/nvm
chown tomw:tomw /usr/local/Git

sudo -u tomw ./set_up_linux_unprivileged.sh

cd /bin
rm sh
ln -s bash sh

# Booting Ubuntu in VMware: Suppressing the warning message: SMBus Host Controllers:
# - Append this to /etc/modprobe.d/blacklist.conf:
#	blacklist i2c_piix4
# - Update the initial RAM file system: # update-initramfs -u
# - Reboot
# E.g. : [ dmesg | grep -i -q smbus ] && { cat "blacklist i2c_piix4" >> /etc/modprobe.conf; update-initramfs -u; }

echo "set_up_linux.sh : Done."

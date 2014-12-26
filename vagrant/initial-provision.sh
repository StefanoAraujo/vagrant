#!/bin/bash

## This file gets executed the first time you do a `vagrant up`, if you want it to
## run again you'll need run `vagrant provision`

## Install all the things
export DEBIAN_FRONTEND=noninteractive

INITIAL_PROVISION_FLAG="/vagrant/vagrant/downloads/apt-get-update.done"
if [ ! -f "$INITIAL_PROVISION_FLAG" ]
then
	touch "$INITIAL_PROVISION_FLAG"
	echo "Updating package list"
	apt-get update >/dev/null
	echo 'Finished updating package list'
fi

echo 'Installing curl'
apt-get -y install curl >/dev/null
echo 'Finished installing curl'

echo 'Installing git'
apt-get -y install git-core >/dev/null
echo 'Finished installing git'

echo 'Installing build-essential packages'
apt-get -y install build-essential >/dev/null
echo 'Finished installing build-essential packages'

echo "Installing base packages"
apt-get install --assume-yes apache2 mysql-client mysql-server supervisor \
	vim ntp bzip2 libpcre3-dev vim libapache2-mod-fcgid expect
echo 'Finished installing base packages'

echo "Installing PHP build dependencies"
# Install all dependencies automatically
apt-get build-dep php5 --assume-yes
apt-get -y install libgmp-dev libmcrypt-dev
# For some reason PHP seems to be looking at the wrong directory for freetype.h
if [[ ! -f /usr/include/freetype2/freetype/freetype.h ]]
then
	mkdir /usr/include/freetype2/freetype
	ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h
fi
# Likewise for gmp.h
if [[ ! -f /usr/include/gmp.h ]]
then
	ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
fi
echo "Finished installing PHP build dependencies"

echo "Tweaking permissions"
## make www-data use /bin/bash for shell
chsh -s /bin/bash www-data

## Tweak permissions for log files
chgrp www-data /var/log/apache2
chmod g+rwx /var/log/apache2
touch /var/log/apache2/access.log
chmod a+r /var/log/apache2/access.log
touch /var/log/apache2/error.log
chmod a+r /var/log/apache2/error.log
touch /var/log/apache2/other_vhosts_access.log
chmod a+r /var/log/apache2/other_vhosts_access.log
mkdir -p /var/log/php
chown www-data:www-data /var/log/php
chmod ug+rwx /var/log/php

## Add the vagrant user to the www-data group
usermod -a -G www-data vagrant

echo "Enabling Apache modules"
## Enable Apache modules we will be needing later on
a2enmod rewrite 1>/dev/null 2>/dev/null
a2enmod vhost_alias 1>/dev/null 2>/dev/null
a2enmod fcgid 1>/dev/null 2>/dev/null

# Prepare for PEAR installation
echo "Preparation for PEAR installation"
GOPEAR=/vagrant/vagrant/downloads/go-pear.php
if [[ ! -f "$GOPEAR" ]]
then
	curl -L "http://pear.php.net/go-pear.phar" -o "$GOPEAR" 1>/dev/null 2>/dev/null
fi
mkdir -p /usr/share/pear

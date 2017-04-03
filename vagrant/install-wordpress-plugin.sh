#!/bin/bash

# Check the number arguments
if [ "$#" -ne 3 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  install-wordpress-plugin.sh source_dir subdomain tag"
	exit 255
fi

SOURCE_DIR=$1
TARGET=/var/www/$2
FLAG_FILE="/vagrant/vagrant/downloads/extension.$2.$3.installed"

export PATH=$PATH:/home/vagrant/.composer/vendor/bin

if [ ! -f "$FLAG_FILE" ]
then
	# Download wp-cli to easily configure WordPress sites
	if [ ! -f "/vagrant/vagrant/downloads/wp-cli.phar" ]; then
		echo "Downloading wp-cli tool"
		curl -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /vagrant/vagrant/downloads/wp-cli.phar
	fi

	# Go into the extension directory and perform initial linking
	pushd "$SOURCE_DIR" > /dev/null
	# Go into the build directory and build the extension
	rm -f "$SOURCE_DIR/release"/*
	popd > /dev/null
	
	pushd "$SOURCE_DIR/build" > /dev/null
	phing git
	popd > /dev/null

	PACKAGE_FILE=`ls "$SOURCE_DIR/release" -1 | egrep ".*wp.*-pro.zip"`
	if [ -z "$PACKAGE_FILE" ]
	then
		PACKAGE_FILE=`ls "$SOURCE_DIR/release" -1 | egrep ".*wp.*.zip"`
	fi
	
	pushd "$TARGET" >/dev/null
	php /vagrant/vagrant/downloads/wp-cli.phar plugin install "$SOURCE_DIR/release/$PACKAGE_FILE" --activate
	popd >/dev/null
	
	echo `pwd`
	chown -R www-data:www-data $TARGET

	# Touch the flag file
	touch "$FLAG_FILE"
fi

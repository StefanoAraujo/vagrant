#!/bin/bash

# Check the number arguments
if [ "$#" -ne 3 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  link-wordpress-extension.sh source_dir subdomain tag"
	exit 255
fi

SOURCE_DIR=$1
TARGET=/var/www/$2
FLAG_FILE="/vagrant/vagrant/downloads/extension.$2.$3.installed"

export PATH=$PATH:/home/vagrant/.composer/vendor/bin

if [ ! -f "$FLAG_FILE" ]
then
	# Download wp-cli to easily configure WordPress sites
	if [ -z "/vagrant/vagrant/downloads/wp-cli.phar" ]; then
		echo "Downloading wp-cli tool"
		curl -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /vagrant/vagrant/downloads/wp-cli.phar
	fi

	# Go into the extension directory and perform initial linking
	cd "$SOURCE_DIR"
	# Go into the build directory and build the extension
	rm -f "$SOURCE_DIR/release"/*
	cd "$SOURCE_DIR/build"
	phing git

	PACKAGE_FILE=`ls "$SOURCE_DIR/release" -1 | egrep ".*wp.*-pro.zip"`
	if [ -z "$PACKAGE_FILE" ]
	then
		PACKAGE_FILE=`ls "$SOURCE_DIR/release" -1 | egrep ".*wp.*.zip"`
	fi
	
	pushd "$TARGET" >/dev/null
	php /vagrant/vagrant/downloads/wp-cli.phar plugin install "$SOURCE_DIR/release/$PACKAGE_FILE" --activate
	popd >/dev/null
	
	chown -R www-data:www-data $TARGET

	# Touch the flag file
	touch "$FLAG_FILE"
fi

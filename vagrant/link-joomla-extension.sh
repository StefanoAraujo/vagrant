#!/bin/bash

# Check the number arguments
if [ "$#" -ne 3 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  link-joomla-library.sh source_dir subdomain tag"
	exit 255
fi

SOURCE_DIR=$1
TARGET=/var/www/$2
FLAG_FILE="/vagrant/vagrant/downloads/extension.$2.$3.installed"

export PATH=$PATH:/home/vagrant/.composer/vendor/bin

if [ ! -f "$FLAG_FILE" ]
then
	# Go into the extension directory and perform initial linking
	cd "$SOURCE_DIR"
	php /mnt/Projects/akeeba/buildfiles/tools/link.php "$SOURCE_DIR"
	# Go into the build directory and build the extension
	rm -f "$SOURCE_DIR/release"/*
	cd "$SOURCE_DIR/build"
	phing link
	phing git
	PACKAGE_FILE=`ls "$SOURCE_DIR/release" -1 | grep "com_.*pro.zip"`
	if [ -z "$PACKAGE_FILE" ]
	then
		PACKAGE_FILE=`ls "$SOURCE_DIR/release" -1 | grep "com_.*.zip"`
	fi

	# Copy the CLI extensions installer into the site's cli directory
	cp "/vagrant/vagrant/files/joomla/install-joomla-extension.php" "$TARGET/cli"
	chown www-data:www-data "$TARGET/cli/install-joomla-extension.php"

	# Install the package file on the site
	pushd "$TARGET/cli" >/dev/null
	php install-joomla-extension.php --package="$1/release/$PACKAGE_FILE"
	popd >/dev/null

	# Touch the flag file
	touch "$FLAG_FILE"
fi

# Finally, symlink the extension
cd "$SOURCE_DIR/build"
phing relink -Dsite="$TARGET"
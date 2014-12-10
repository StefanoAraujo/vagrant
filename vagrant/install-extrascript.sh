#!/bin/bash

if [ "$#" -ne 2 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  install-extrascript.sh url_to_download subdomain"
	echo "Where:"
	echo "  url_to_download  URL of the script sources"
	echo "  subdomain        The subdomain/subdorectory to install to"
	exit 255
fi

DOWNLOAD_URL=$1
DOWNLOAD_FILE="/vagrant/vagrant/downloads/$2.tar.gz"
TARGET_PATH="/var/www/$2"
FLAG_FILE="/vagrant/vagrant/downloads/extrascript.$2.installed"
CUSTOM_FILES="/vagrant/vagrant/files/$2"

# Configure and build PHP
if [ ! -f "$FLAG_FILE" ]
then
	# Download the source files, if required
	if [ ! -f "$DOWNLOAD_FILE" ]
	then
		echo "Downloading $2"
		curl -L "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE" 1>/dev/null 2>/dev/null
		echo "Done downloading $2"
	fi

	if [ ! -f "$DOWNLOAD_FILE" ]
	then
		echo "Failed installing $2"
		exit 1;
	fi

	# Create the build directory
	echo "Extracting the sources to $TARGET_PATH"
	mkdir -p "$TARGET_PATH"
	tar xzf "$DOWNLOAD_FILE" -C "$TARGET_PATH" --strip-components=1 1>/dev/null 2>/dev/null
	chown -Rvf www-data:www-data "$TARGET_PATH"
	chmod 0755 "$TARGET_PATH"
	find "$TARGET_PATH" -type d -exec chmod 0755 \{} \;
	find "$TARGET_PATH" -type f -exec chmod 0644 \{} \;
	echo "Done extracting the sources to $TARGET_PATH"

	if [ -d "$CUSTOM_FILES" ]
	then
		echo "Copying custom files for $2"
		cp -Rvf "$CUSTOM_FILES"/* "$TARGET_PATH"
		echo "Done copying custom files for $2"
	fi

	touch "$FLAG_FILE"
fi
#!/bin/bash
# Check the number arguments
if [ "$#" -ne 2 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  install-php.sh url_to_download php_with_version"
	echo "Where:"
	echo "  url_to_download  URL of XDebug sources"
	echo "  php_with_version e.g. php56 for PHP 5.6"
	exit 255
fi

DOWNLOAD_URL=$1
BASENAME=`basename $1`
DOWNLOAD_FILE="/vagrant/vagrant/downloads/$BASENAME"
FLAG_FILE="/vagrant/vagrant/downloads/$2.xdebug.installed"

if [ ! -f "$FLAG_FILE" ]
then
	touch "$FLAG_FILE"

	# Download the source files, if required
	if [ ! -f "$DOWNLOAD_FILE" ]
	then
		echo "Downloading $2"
		curl -L "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE" 1>/dev/null 2>/dev/null
		echo "Done downloading $2"
	fi

	# Create the build directory
	echo "Extracting the sources to /usr/local/src/xdebug-$2"
	cd /usr/local/src
	mkdir -p xdebug-$2
	tar xzf "$DOWNLOAD_FILE" -C "xdebug-$2" --strip-components=1 # 1>/dev/null 2>/dev/null
	echo "Done extracting the sources to /usr/local/src/xdebug-$2"

	echo "Configuring and building XDebug ($2). This will take a while."
	cd /usr/local/src/xdebug-$2

	PHP_API_VERSION=`ls /usr/share/$2/lib/php | grep 20`
	[[ -e /usr/include/php ]] & rm /usr/include/php
	ln -s /usr/include/$2 /usr/include/php
	/usr/bin/$2/phpize
	./configure --enable-xdebug --with-php-config=/usr/bin/$2/php-config
	make
	[[ -e /usr/include/php ]] & rm /usr/include/php

	echo "Done configuring and building XDebug ($2)."
fi

echo "Installing XDebug ($2)"
cp /usr/local/src/xdebug-$2/modules/xdebug.so /usr/share/$2/lib/php/$PHP_API_VERSION
echo "Done installing XDebug ($2)"
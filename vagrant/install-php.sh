#!/bin/bash
# Check the number arguments
if [ "$#" -ne 4 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  install-php.sh url_to_download php_with_version is_default hostname"
	echo "Where:"
	echo "  url_to_download  URL of PHP sources"
	echo "  php_with_version e.g. php56 for PHP 5.6"
	echo "  is_default       1 for default PHP version (symlinked)"
	echo "  hostname         The hostname for this php version, e.g. vagrant56.up"
	exit 255
fi

DOWNLOAD_URL=$1
DOWNLOAD_FILE="/vagrant/vagrant/downloads/$2.tar.bz2"
TARGET_PATH="/usr/share/$2"
BIN_PATH="/usr/bin/$2"
APACHE_CONFIG_PATH="/etc/$2/apache2"
CLI_CONFIG_PATH="/etc/$2/cli"
CONFD_CONFIG_PATH="/etc/$2/conf.d"
SOURCE_CONFIG="/vagrant/vagrant/files/php/$2"
FLAG_FILE="/vagrant/vagrant/downloads/$2.installed"

# Copy configuration files
echo "Installing configuration files"
rm -rf "/etc/$2"
if [ -d "$SOURCE_CONFIG" ]
then
	cp -Rvf "$SOURCE_CONFIG" "/etc" >/dev/null
fi

# Symlink from mods-available to apache2/conf.d and cli/conf.d
MODS01=( magic-quotes )
MODS05=( opcache )
MODS10=( mysqlnd pdo )
MODS20=( curl gd gmp imagick intl json ldap mailcatcher mongo mysql mysqli oauth odbc pdo_mysql pdo_odbc pdo_pgsql pdo_sqlite pgsql pspell readline recode redis sasl sqlite3 tidy xcache xdebug xmlrpc xsl )
DIRS=( apache2 cli )

for dir in "${DIRS[@]}"
do
	for m in ${MODS01[@]}
	do
		if [ -e "/etc/$2/mods-available/$m.ini" ]
		then
			[ -e "/etc/$2/$dir/conf.d/01-$m.ini" ] && rm -f "/etc/$2/$dir/conf.d/01-$m.ini"
			ln -s "/etc/$2/mods-available/$m.ini" "/etc/$2/$dir/conf.d/01-$m.ini"
		fi
	done

	for m in ${MODS05[@]}
	do
		if [ -e "/etc/$2/mods-available/$m.ini" ]
		then
			[ -e "/etc/$2/$dir/conf.d/05-$m.ini" ] && rm -f "/etc/$2/$dir/conf.d/05-$m.ini"
			ln -s "/etc/$2/mods-available/$m.ini" "/etc/$2/$dir/conf.d/05-$m.ini"
		fi
	done

	for m in ${MODS10[@]}
	do
		if [ -e "/etc/$2/mods-available/$m.ini" ]
		then
			[ -e "/etc/$2/$dir/conf.d/10-$m.ini" ] && rm -f "/etc/$2/$dir/conf.d/10-$m.ini"
			ln -s "/etc/$2/mods-available/$m.ini" "/etc/$2/$dir/conf.d/10-$m.ini"
		fi
	done

	for m in ${MODS20[@]}
	do
		if [ -e "/etc/$2/mods-available/$m.ini" ]
		then
			[ -e "/etc/$2/$dir/conf.d/20-$m.ini" ] && rm -f "/etc/$2/$dir/conf.d/20-$m.ini"
			ln -s "/etc/$2/mods-available/$m.ini" "/etc/$2/$dir/conf.d/20-$m.ini"
		fi
	done
done

# Create a generic conf.d linking to cli/conf.d
[ -L "/etc/$2/conf.d" ] && rm "/etc/$2/conf.d"
ln -s "/etc/$2/cli/conf.d" "/etc/$2/conf.d"

echo "Done installing configuration files"

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

	# Create the build directory
	echo "Extracting the sources to /usr/local/src/$2"
	cd /usr/local/src
	mkdir -p $2
	tar xjf "$DOWNLOAD_FILE" -C "$2" --strip-components=1 1>/dev/null 2>/dev/null
	echo "Done extracting the sources to /usr/local/src/$2"

	echo "Configuring and building PHP ($2). This will take a while."
	touch "$FLAG_FILE"
	cd /usr/local/src/$2

	./configure \
	  --prefix="$TARGET_PATH" \
	  --datadir="$TARGET_PATH" \
	  --mandir=/usr/share/man \
	  --bindir="$BIN_PATH" \
	  --with-libdir=lib64 \
	  --includedir=/usr/include \
	  --sysconfdir="$APACHE_CONFIG_PATH" \
	  --with-config-file-path="$CLI_CONFIG_PATH" \
	  --with-config-file-scan-dir="$CONFD_CONFIG_PATH" \
	  --localstatedir=/var \
	  --disable-debug \
	  --with-regex=php \
	  --disable-rpath \
	  --disable-static \
	  --disable-posix \
	  --with-pic \
	  --with-layout=GNU \
	  --with-pear=/usr/share/php \
	  --enable-calendar \
	  --enable-sysvsem \
	  --enable-sysvshm \
	  --enable-sysvmsg \
	  --enable-bcmath \
	  --with-bz2 \
	  --enable-ctype \
	  --with-db4 \
	  --without-gdbm \
	  --with-iconv \
	  --enable-exif \
	  --enable-ftp \
	  --enable-cli \
	  --with-gettext \
	  --enable-mbstring \
	  --with-pcre-regex=/usr \
	  --enable-shmop \
	  --enable-sockets \
	  --enable-wddx \
	  --with-libxml-dir=/usr \
	  --with-zlib \
	  --with-kerberos=/usr \
	  --with-openssl=/usr \
	  --enable-soap \
	  --enable-zip \
	  --with-mhash \
	  --with-exec-dir="/usr/lib/$2/libexec" \
	  --without-mm \
	  --with-curl=shared,/usr \
	  --with-zlib-dir=/usr \
	  --with-gd=shared,/usr \
	  --enable-gd-native-ttf \
	  --with-gmp=shared,/usr \
	  --with-jpeg-dir=shared,/usr \
	  --with-xpm-dir=shared,/usr/X11R6 \
	  --with-png-dir=shared,/usr \
	  --with-freetype-dir=shared,/usr \
	  --with-ttf=shared,/usr \
	  --with-ldap=shared,/usr \
	  --with-mysql=shared,/usr \
	  --with-mysqli=shared,/usr/bin/mysql_config \
	  --with-pgsql=shared,/usr \
	  --with-pspell=shared,/usr \
	  --with-unixODBC=shared,/usr \
	  --with-xsl=shared,/usr \
	  --with-snmp=shared,/usr \
	  --with-sqlite=shared,/usr \
	  --with-tidy=shared,/usr \
	  --with-xmlrpc=shared \
	  --enable-pdo=shared \
	  --without-pdo-dblib \
	  --with-pdo-mysql=shared,/usr \
	  --with-pdo-pgsql=shared,/usr \
	  --with-pdo-odbc=shared,unixODBC,/usr \
	  --with-pdo-dblib=shared,/usr \
	  --enable-force-cgi-redirect  --enable-fastcgi \
	  --with-libdir=/lib/x86_64-linux-gnu \
	  --with-pdo-sqlite=shared \
	  --with-sqlite=shared \
	  --enable-ipv6 \
	  --with-mcrypt \
	  --with-imap=/usr/lib \
	  --with-imap-ssl 1>/dev/null 2>/dev/null \
	&& make 1>/dev/null 2>/dev/null
	make install 1>/dev/null 2>/dev/null

	rm -rf /usr/include/$2
	mv /usr/include/php /usr/include/$2

	echo "Done configuring and building PHP ($2)."
fi

# Symlink the default PHP version
if [ $3 -eq 1 ]
then
	echo "Symlinking default PHP version ($2) to /usr/bin"
	MYFILES=( php phar phar.phar php-config phpize )
	for f in ${MYFILES[@]}
	do
		[ -e "/usr/bin/$f" ] && rm "/usr/bin/$f"
		ln -s "/usr/bin/$2/$f" "/usr/bin/$f"
	done
	echo "Done symlinking"
fi

# If this is the default PHP version, create the main PHP configuration for Apache
if [ $3 -eq 1 ]
then
	# Create the default PHP configuration using the default PHP version
	sed -e "s/PHPVER/$2/g" /vagrant/vagrant/files/apache2/fcgid-template.conf > /etc/apache2/conf-available/php-fcgid.conf
	a2enconf php-fcgid
	# Also create a phpinfo.php file to let you check if PHP is working
	echo "<?php
phpinfo();
	" > /var/www/html/phpinfo.php
fi

# Create a virtual host domain for the PHP version
sed -e "s/PHPVER/$2/g" -e "s/PHPDOMAIN/$4/g" \
/vagrant/vagrant/files/apache2/phphost-template.conf > /etc/apache2/sites-available/$2.conf
a2ensite $2
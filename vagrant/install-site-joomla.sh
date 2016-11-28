#!/bin/bash
########################################################################################################################
# Install a Joomla! site on a Vagrant box
#
# This script downloads the latest Joomla! version from the web and caches it on the current directory. It will then
# create a new database for the Joomla! site and install the site on your server.
#
# Syntax:
#     install-joomla.sh source subdirectory
#
# Example:
#     install-joomla.sh latest dev31
#     install-joomla.sh /usr/local/src/joomla dev31
#
########################################################################################################################

# ======================================================================================================================
# Configuration
# ======================================================================================================================
DB_HOST="127.0.0.1"
DB_USER="root"
DB_PASS=""

# ======================================================================================================================
# All the action takes place below. Do not modify unless You Know Exactly What You Are Doing™
# ======================================================================================================================

# Check the number arguments
if [ "$#" -ne 2 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  install-joomla.sh source subdirectory"
	echo "Where:"
	echo "  source        Installation source. Either 'latest' or a path."
	echo "  subdirectory  Subdir to create; also db name, db username and db password"
	exit 255
fi

TARGET_DIR="/var/www/$2"

echo "Preparing to install Joomla! to $TARGET_DIR"

# Check if the site is already installed
if [ -d "$TARGET_DIR" ]
then
	echo "The Joomla! site $2 is already installed at $TARGET_DIR; skipping."
	exit 0;
fi

if [ "$1" = "latest" ]
then
	# Find the latest Joomla! version's download URL – e.g. https://github.com/joomla/joomla-cms/releases/download/3.3.6/Joomla_3.3.6-Stable-Full_Package.zip
	LATEST_JOOMLA_URL=https://downloads.joomla.org`curl -L -s "https://downloads.joomla.org/latest" -o - | grep "href=\"/cms/joomla3/" | head -n 1 | grep -o '"/cms/[^"]*"' | grep -o '/cms/[^"]*' | head -n 1`

	# Get the base name of the latest Joomla! version download URL – e.g. Joomla_3.3.6-Stable-Full_Package.zip
	JOOMLA_BASENAME=`echo ${LATEST_JOOMLA_URL##*/} | grep -o "joomla[-_ 0-9]*"`.zip

	PACKAGE_TARGET="/vagrant/vagrant/downloads/$JOOMLA_BASENAME"

	# If the latest version doesn't exist, fetch it from the web
	if [ ! -f "$PACKAGE_TARGET" ]
	then
		echo "Downloading Joomla! package $JOOMLA_BASENAME"
		# Remove old downloads
		rm -f Joomla_*.zip
		# Fetch from the web
		curl -L -Ss "$LATEST_JOOMLA_URL" -o "$PACKAGE_TARGET" >/dev/null
	fi

	# If the download still doesn't exist, complain and die
	if [ ! -f "$PACKAGE_TARGET" ]
	then
		echo Could not download Joomla! package "$JOOMLA_BASENAME"
		exit 1;
	fi

	# Extract into a temporary directory
	rm -rf /tmp/joomla
	mkdir -p /tmp/joomla
	cd /tmp/joomla
	unzip "$PACKAGE_TARGET" >/dev/null

	SOURCE_DIR=/tmp/joomla
else
	SOURCE_DIR=$1
fi

# Remove the subdirectory if it already exists
echo "Creating directory $TARGET_DIR"
if [ -d "$TARGET_DIR" ]
then
	rm -rf "$TARGET_DIR"
fi

# Create the new database and grant privileges
echo "Creating database $2"
sed -e "s/MYDBNAME/$2/g" /vagrant/vagrant/files/joomla/install_joomla_create_db.sql | mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS"

# Copy or link the Joomla! files to the target directory
if [ "$1" = "latest" ]
then
	echo "Copying Joomla! files"
	mkdir -p "$TARGET_DIR"
	cp -Rf "$SOURCE_DIR"/* "$TARGET_DIR"
else
	ln -s "$SOURCE_DIR" "$TARGET_DIR"
fi

# Create a new configuration.php
echo "Creating new configuration.php"
SITE_SECRET=`openssl rand -base64 32 2> /dev/null`
sed -e "s/MYSITE/$2/g" -e "s/DBHOST/$DB_HOST/g" -e 's#SITESECRET#'$SITE_SECRET'#g' -e 's#ROOTPATH#/var/www#g' \
/vagrant/vagrant/files/joomla/configuration.php > "$TARGET_DIR/configuration.php"

# If we have a SQL dump, install it
DUMP_FILE="/vagrant/vagrant/files/joomla/$2.sql"
if [ -f "$DUMP_FILE" ]
then
	echo "Populating database from custom dump file $DUMP_FILE"
	sed -e "s/#__/$2_/g" "$DUMP_FILE" | mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" $2
else
	# Populate database with main Joomla! tables
	echo "Populating database from distribution (core)"
	sed -e "s/#__/$2_/g" "$TARGET_DIR/installation/sql/mysql/joomla.sql" | mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" $2

	# Install sample data
	echo "Populating database from distribution (sample data)"
	sed -e "s/#__/$2_/g" "$TARGET_DIR/installation/sql/mysql/sample_learn.sql" | mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" $2

	# Install admin user (username and password are the same as the subdirectory)
	echo "Creating Super User with login $2/$2"
	ADMIN_ID="$((RANDOM%900+100))"
	ADMIN_PW=`php /vagrant/vagrant/files/joomla/mkpasswd.php "$2"`
	sed -e "s/#__/$2_/g" -e "s/ADMIN_ID/$ADMIN_ID/g" -e "s/ADMIN_NAME/$2/g" -e 's#ADMIN_PW#'$ADMIN_PW'#g' \
	/vagrant/vagrant/files/joomla/install_joomla_admin_user.sql | mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS" $2
fi

# Create .htaccess file
CUSTOM_HTACCESS="/vagrant/vagrant/files/joomla/htaccess.$2.txt"
if [ -f "$CUSTOM_HTACCESS" ]
then
	echo "Creating .htaccess from custom file $CUSTOM_HTACCESS"
	cp "$CUSTOM_HTACCESS" "$TARGET_DIR/.htaccess"
else
	echo "Creating .htaccess from dist file htaccess.txt"
	cp "$TARGET_DIR/htaccess.txt" "$TARGET_DIR/.htaccess"
fi

# If we're installing from latest package
if [ "$1" = "latest" ]
then
	echo "Removing the installation directory"
	rm -rf "$TARGET_DIR/installation"

	echo "Fixing ownership"
	chown -Rf www-data:www-data "$TARGET_DIR"
fi
#!/bin/bash
########################################################################################################################
# Install a WordPress site on a Vagrant box
#
# This script downloads the latest WordPress version from the web and caches it on the current directory. It will then
# create a new database for the WordPress site and install the site on your server.
#
# Syntax:
#     install-wordpress.sh source subdirectory
#
# Example:
#     install-wordpress.sh latest dev31
#     install-wordpress.sh /usr/local/src/joomla dev31
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
	echo "  install-wordpress.sh source subdirectory"
	echo "Where:"
	echo "  source        Installation source. Either 'latest' or a path."
	echo "  subdirectory  Subdir to create; also db name, db username and db password"
	exit 255
fi

TARGET_DIR="/var/www/$2"

echo "Preparing to install WordPress to $TARGET_DIR"

# Check if the site is already installed
if [ -d "$TARGET_DIR" ]
then
	echo "The WordPress site $2 is already installed at $TARGET_DIR; skipping."
	exit 0;
fi

# First of all create the new database and grant privileges
echo "Creating database $2"
sed -e "s/MYDBNAME/$2/g" /vagrant/vagrant/files/wordpress/install_wordpress_create_db.sql | mysql -h "$DB_HOST" -u "$DB_USER" --password="$DB_PASS"

# Download wp-cli to easily configure WordPress sites
if [ -z "/vagrant/vagrant/downloads/wp-cli.phar" ]; then
	echo "Downloading wp-cli tool"
	curl -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /vagrant/vagrant/downloads/wp-cli.phar
fi

# Download the desired version
echo "Downloading WordPress"
php /vagrant/vagrant/downloads/wp-cli.phar core download --path=$TARGET_DIR --version=$1

# Create the wp-config.php file
echo "Creating wp-config.php file"
php /vagrant/vagrant/downloads/wp-cli.phar core config --dbname=$2 --dbuser=$DB_USER --dbpass=$DB_PASS --dbhost=$DB_HOST --path=$TARGET_DIR

# Ok now, we're ready to actually install WordPress
echo "Installing WordPress..."
php /vagrant/vagrant/downloads/wp-cli.phar core install --title=WordPress --admin_user=$2 --admin_email=$2@localhost.localdomain --admin_password=$2 --skip-email --url=$2.vagrant54.up --path=$TARGET_DIR

echo "Fixing ownership"
chown -Rf www-data:www-data "$TARGET_DIR"

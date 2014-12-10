#!/bin/bash

# Install composer
cd /tmp
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install PHPUnit
cd /tmp
curl -sS https://phar.phpunit.de/phpunit.phar -O
chmod a+x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

# Install Phing
pear config-set preferred_state alpha
pear config-set auto_discover 1
pear channel-discover pear.phing.info
pear install --alldeps phing/phing
pear config-set auto_discover 0
pear config-set preferred_state stable

# Install PHP CodeSniffer
cd /tmp
curl -OSsL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
curl -OSsL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar
chmod a+x phpcs.phar
mv phpcs.phar /usr/local/bin/phpcs
chmod a+x phpcbf.phar
mv phpcbf.phar /usr/local/bin/phpcbf

# Install PHP Mess Detector
sudo -H -u vagrant composer global require phpmd/phpmd:@stable

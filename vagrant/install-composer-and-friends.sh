#!/bin/bash

# Install composer
cd /tmp
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# Install Phing and its dependencies
sudo -H -u vagrant composer global config minimum-stability stable
sudo -H -u vagrant composer global require phing/phing
sudo -H -u vagrant composer global require phpdocumentor/phpdocumentor
sudo -H -u vagrant composer global require sebastian/phpcpd
sudo -H -u vagrant composer global require pdepend/pdepend
sudo -H -u vagrant composer global require phploc/phploc
sudo -H -u vagrant composer global require pear/versioncontrol_svn
sudo -H -u vagrant composer global require pear/archive_tar
sudo -H -u vagrant composer global require tedivm/jshrink

# The pear/git package is unstable, so let's let usntable packages to be installed temporarily
sudo -H -u vagrant composer global config minimum-stability dev
sudo -H -u vagrant composer global require pear/versioncontrol_git
sudo -H -u vagrant composer global config minimum-stability beta

# Install PHPUnit and its dependencies
sudo -H -u vagrant composer global require phpunit/phpunit
# -- this requires the pcntl extension which is currently not installed
#sudo -H -u vagrant composer global require phpunit/php-invoker
sudo -H -u vagrant composer global require phpunit/php-code-coverage


# Install PHP CodeSniffer
sudo -H -u vagrant composer global require squizlabs/php_codesniffer

# Install PHP Mess Detector
sudo -H -u vagrant composer global require phpmd/phpmd
#!/bin/bash

# Install Mailcatcher
gem install mailcatcher

# This file may have just been updated. It adds the Ruby Gems executables directory to the PATH, required to start the service
source /etc/profile.d/rvm.sh

RUBYPATH=`which ruby`
MCPATH=`which mailcatcher`
sed -e "s#MCPATH#$MCPATH#g" -e "s#RUBYPATH#$RUBYPATH#g" "/vagrant/vagrant/files/mailcatcher/mailcatcher.conf" > /etc/init/mailcatcher.conf

service mailcatcher restart
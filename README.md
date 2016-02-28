# Akeeba Dev Box

A Vagrant server for Joomla! core and extension development.

**ATTENTION: We consider this to be always work in progress**. Backup your data before spinning up this dev box.

**NO WARRANTY**. I wrote and documented this for my personal use. It's what I use to create servers for development and testing. I accept no responsibility or liability whatsoever if any third party decides to use it. If something broke and you know how to fix it feel free to send me a Pull Request through GitHub.

## Ingredients

In other words, here's what you get when you install a server using this repository.

* Ubuntu Server
* MySQL
* Apache, with automatic subdomain hosting
* Different PHP versions (PHP 5.3, 5.4, 5.5, 5.6, 7.0), one domain per PHP version: vagrant53.up for PHP 5.3, vagrant54.up for PHP 5.4, vagrant55.up for PHP 5.5, vagrant56.up for PHP 5.6, vagrant70.up for PHP 7.0. All compiled from scratch.
* XDebug, one port per PHP version: 9053 for PHP 5.3, 9054 for PHP 5.4, 9055 for PHP 5.5, 9056 for PHP 5.6, 9070 for PHP 7.0. Compiled from scratch.
* PEAR
* Phing
* Composer
* PHPUnit
* PHP Code Sniffer (phpcs)
* PHP Mess Detector (phpmd)
* phpMyAdmin at http://phpMyAdmin.vagrant55.up (note: newer versions of phpMyAdmin do not work with PHP 5.3 and 5.4)
* Pimp My Log at http://pml.vagrant54.up
* MailCatcher at http://vagrant.up:1080
* Two latest Joomla! 3 sites freshly installed at dev3.vagrant54.up and test3.vagrant54.up (and the respective vagrant53.up, vagrant55.up etc for testing with other PHP versions)
* Optional: Joomla! CMS development site freshly installed at jdev.vagrant54.up (and the respective vagrant53.up, vagrant55.up etc for testing with other PHP versions) from sources you've already provided yourself – See below
* Optional: Automatic build, install and symlinking of Akeeba extensions to the dev3 site. If you're not Akeeba staff you can ignore that part.

## Pre-requisites

* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com) 1.5 or later (built on 1.6)
* [Vagrant Cachier plugin](https://github.com/fgrehm/vagrant-cachier). Install with `vagrant plugin install vagrant-cachier`. Used to cache the Ubuntu packages used to build the Virtual Machines.
* [Vagrant HostManager plugin](https://github.com/smdahlen/vagrant-hostmanager). Install with `vagrant plugin install vagrant-hostmanager`. Used to modify your hosts file to let you access your Virtual Machine.

## Setup

You can configure the server build process by editing the `vagrant/config.yaml` file. Fine tuning of server configuration files (for expert users only) requires editing the files under `vagrant/files`.

### Configuration for most people (non Akeeba staff)

Copy the `vagrant/config_projects.yaml-dist` to `vagrant/config_projects.yaml`

Edit the `vagrant/config_projects.yaml` file and change the following:

Things you **MUST** change:
* `source: ~/Projects` under "myProjects". Change `~/Projects` to the path of your local computer's directory where you put your extensions' source code. This path is mounted to `/mnt/Projects` inside the virtual machine

Copy the `vagrant/config_sites.yaml-dist` to `vagrant/config_sites.yaml`

Edit the `vagrant/config_sites.yaml` file and change the following:

Things you **MUST** change:
* `source: /mnt/Projects/master/joomla-cms` Change master/joomla-cms to the relative path inside your project's directory where the Joomla! CMS working copy is. If it is the Projects directory itself, this line should read `source: /mnt/Projects`

Run `vagrant up` from the main directory to build the server. WARNING: Building the server can take up to one hour since we're compiling all PHP versions from source.


### Configuration for Akeeba staff

Things you **MUST** change:
* `source: ~/Projects` under "myProjects". Change `~/Projects` to the path of your local computer's directory where you put the project files. There MUST be a directory called `akeeba` inside it where you check out the Akeeba repos. You also need a directory `master/joomla-cms` inside the Projects folder; this is where the latest Joomla! staging branch lives.
* You may want to remove installsites/jdev and/or edit the source of installsites and extensions if you do not follow the recommended directory layout in Projects.

Run `vagrant up` from the main directory to build the server. WARNING: Building the server can take up to one hour since we're compiling all PHP versions from source.

### Updating

Every so often we update this repository with newer versions of PHP, XDebug, phpMyAdmin etc. In order to stay up to date you generally need to run `vagrant provision`. This will install new version branches of PHP as long as they have not been installed. It will NOT update existing PHP versions, e.g. it won't upgrade PHP 5.6.15 to 5.6.16.

However, if you want to update already installed software you need to delete some files from the `vagrant/downloads` directory:
* `phpXY.installed` and `phpXY.tar.bz2` (where XY is a PHP version branch, e.g. 56) to let the provisioning script overwrite a version branch of PHP with a newer version. For example, deleting `php56.installed` and `php56.tar.bz2` allows the provision script to update PHP 5.6 to the latest version defined in `config.yaml`. Please note that removing these files will recompile PHP which does take a lot of time! As a rule of thumb, delete the files for PHP 5.5, 5.6 and 7.0 (PHP 5.3 and 5.4 are EOL – they do not receive updates any more). 
* `phpXY.xdebug.installed` to update XDebug for a specific PHP version
* `extrascript.phpmyadmin.installed` and `phpmyadmin.tar.gz` to reinstall/update phpMyAdmin
* `extrascript.pml.installed` and `pml.tar.gz` to reinstall/update PML (Pimp My Log)

If you have defined extra scripts in your `config.yaml` you will see the respective `extrascript.KEY.installed` and `KEY.tar.gz` files where KEY is the extra script's key under the extrascripts label in your config.yaml.

## Useful information for installed software

### Usernames and passwords

The system user is `vagrant` with password `vagrant`. You can use it for SSH and SFTP.

All sites run under the `www-data` user and group. The `/mnt/Projects` directory is owned by `www-data` to let you develop with ease.

The database administrator username is `root` with an empty password. Please note that phpMyAdmin doesn't allow you to connect with an empty password. Do not change the root password, it will prevent provision scripts from running.

Each Joomla! site's database name, username and password is named after the site. For example, the dev3 site has its data installed in the `dev3` database accessible with username `dev3` and password `dev3`.

Each Joomla! site's Super User username and password is named after the site. For example, the dev3 site has a Super User with username `dev3` and password `dev3`.

### phpMyAdmin

If you want to manage your database server you should preferably use a tool such as Sequel Pro. Just connect with hostname vagrant.up, username root and no password. Alternatively you can use phpMyAdmin at http://vagrant54.up/phpmyadmin

The database administrator username is `root` with an empty password. Please note that phpMyAdmin doesn't allow you to connect with an empty password. Please use one of the already created users instead.

### Pimp My Log

You can view the Apache and PHP log files by going to http://pml.vagrant54.up  This is a tool called Pimp My Log. If you're using a modern browser it can send you desktop notifications when a new log entry is created. Do note that there are different log files for each PHP version's CLI and web server messages.

### MailCatcher

MailCatcher catches emails sent from your site instead of sending them over the Internet. This allows you to perform tests with email sends without burning your email quota or accidentally sending messages to real people.

You can access MailCatcher's interface at http://vagrant.up:1080

Each Joomla! site is already configure to use MailCatcher. As you can see, we use Sendmail as the mail server type and a special programme to act as the sendmail command. Note that the email address after the -f parameter must match the From Email setting in Joomla!'s Global Configuration. The default sendmail command for MailCatcher is `/usr/bin/env catchmail -f server@vagrant.up` where `server@vagrant.up` is the From Email address configured in Joomla! Global Configuration.

### Developing against multiple PHP versions

The PHP version used to serve your site depends on the domain name you use. We have four domain names:

* `vagrant53.up` for PHP 5.3
* `vagrant54.up` for PHP 5.4
* `vagrant55.up` for PHP 5.5
* `vagrant56.up` for PHP 5.6
* `vagrant70.up` for PHP 7.0

This means that the dev3 site can be served by these different URLs:

* `http://dev3.vagrant53.up` for PHP 5.3
* `http://dev3.vagrant54.up` for PHP 5.4
* `http://dev3.vagrant55.up` for PHP 5.5
* `http://dev3.vagrant56.up` for PHP 5.6
* `http://dev3.vagrant70.up` for PHP 7.0

The subdomain (leftmost part of the domain name in the URL) is the same as the `/var/www` subdirectory where the site's files are located in. You can create as many sites as you want, as long as you've added the necessary aliases in your computer's host file.

Each PHP version also has a different XDebug port it listens to:

* 9053 for PHP 5.3 (vagrant53.up domain)
* 9054 for PHP 5.4 (vagrant54.up domain)
* 9055 for PHP 5.5 (vagrant55.up domain)
* 9056 for PHP 5.6 (vagrant56.up domain)
* 9070 for PHP 7.0 (vagrant70.up domain)

Got it? It's 90 and the PHP major and minor version. It's very simple to remember.

Beware! This is a development environment. XDebug is configured to allow anyone to connect to it, no matter what their IP address is.

### What to do if the hosts update doesn't work out of the box

If you cannot access the vagrant.up, vagrant53.up etc domains you need to edit your hosts file yourself and add the following lines:

```
192.168.64.3		phpmyadmin.vagrant53.up phpmyadmin.vagrant54.up phpmyadmin.vagrant55.up phpmyadmin.vagrant56.up phpmyadmin.vagrant70.up
192.168.64.3		pml.vagrant53.up pml.vagrant54.up pml.vagrant55.up pml.vagrant56.up pml.vagrant70.up
192.168.64.3		dev3.vagrant.up test3.vagrant.up www.vagrant.up vagrant.up
192.168.64.3		jdev.vagrant53.up dev3.vagrant53.up test3.vagrant53.up www.vagrant53.up vagrant53.up
192.168.64.3		jdev.vagrant54.up dev3.vagrant54.up test3.vagrant54.up www.vagrant54.up vagrant54.up
192.168.64.3		jdev.vagrant55.up dev3.vagrant55.up test3.vagrant55.up www.vagrant55.up vagrant55.up
192.168.64.3		jdev.vagrant56.up dev3.vagrant56.up test3.vagrant56.up www.vagrant56.up vagrant56.up
192.168.64.3		jdev.vagrant70.up dev3.vagrant70.up test3.vagrant70.up www.vagrant70.up vagrant70.up
```

How to do that depends on your operating system:

* Mac OS X: Use [GasMask](http://www.clockwise.ee/gasmask/)
* Linux: edit the file `/etc/hosts`, e.g. `gksudo gedit /etc/hosts`
* Windows: Use [HostsEditor](https://hostseditor.codeplex.com)

Further information on editing your hosts file can be found on [HowToGeek](http://www.howtogeek.com/howto/27350/beginner-geek-how-to-edit-your-hosts-file/).

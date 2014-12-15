# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

dir = File.dirname(File.expand_path(__FILE__))

configValues = YAML.load_file("#{dir}/vagrant/config.yaml")
data         = configValues['vagrantfile-local']

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Run hostmanager as the very last action
  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = false
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.aliases = Array.new
  end

  # Which box should I use?
  config.vm.box = "#{data['vm']['box']}"
  config.vm.box_url = "#{data['vm']['box_url']}"

  config.vm.define "devbox" do |devbox|
    if Vagrant.has_plugin?("vagrant-hostmanager")
      devbox.hostmanager.aliases = Array.new
    end

    # Set up the hostname of the guest, if specified
    if data['vm']['hostname'].to_s.strip.length != 0
      devbox.vm.hostname = "#{data['vm']['hostname']}"
    end

    # Set up automatic update checks
    if !data['vm']['box_check_update'].nil?
      devbox.vm.box_check_update = "#{data['vm']['box_check_update']}"
    end

    # Set up forwarded ports
    data['vm']['network']['forwarded_port'].each do |i, port|
      if port['guest'] != '' && port['host'] != ''
        devbox.vm.network :forwarded_port, guest: port['guest'].to_i, host: port['host'].to_i
      end
    end

    # A message to show after vagrant up
    if !data['vm']['post_up_message'].nil?
      devbox.vm.post_up_message = "#{data['vm']['post_up_message']}"
    end

    # Create a private network
    if data['vm']['network']['private_network'].to_s != ''
      devbox.vm.network 'private_network', ip: "#{data['vm']['network']['private_network']}"
    end

    # Create a public network
    if !data['vm']['public_network'].to_i == 1
      devbox.vm.network "public_network"
    end

    # Configure SSH access to the Vagrant box
    if !data['ssh']['host'].nil?
      config.ssh.host = "#{data['ssh']['host']}"
    end
    if !data['ssh']['port'].nil?
      config.ssh.port = "#{data['ssh']['port']}"
    end
    if !data['ssh']['username'].nil?
      config.ssh.username = "#{data['ssh']['username']}"
    end
    if !data['ssh']['guest_port'].nil?
      config.ssh.guest_port = data['ssh']['guest_port']
    end
    if !data['ssh']['shell'].nil?
      config.ssh.shell = "#{data['ssh']['shell']}"
    end
    if !data['ssh']['keep_alive'].nil?
      config.ssh.keep_alive = data['ssh']['keep_alive']
    end
    if !data['ssh']['forward_agent'].nil?
      config.ssh.forward_agent = data['ssh']['forward_agent']
    end
    if !data['ssh']['forward_x11'].nil?
      config.ssh.forward_x11 = data['ssh']['forward_x11']
    end

    # Set up folder shares
    data['vm']['synced_folder'].each do |i, folder|
      if folder['source'] != '' && folder['target'] != ''
        sync_owner = !folder['sync_owner'].nil? ? folder['sync_owner'] : 'www-data'
        sync_group = !folder['sync_group'].nil? ? folder['sync_group'] : 'www-data'

        if folder['sync_type'] == 'nfs'
          devbox.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}", type: 'nfs'
        elsif folder['sync_type'] == 'smb'
          devbox.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}", type: 'smb'
        elsif folder['sync_type'] == 'rsync'
          rsync_args = !folder['rsync']['args'].nil? ? folder['rsync']['args'] : ['--verbose', '--archive', '-z']
          rsync_auto = !folder['rsync']['auto'].nil? ? folder['rsync']['auto'] : true
          rsync_exclude = !folder['rsync']['exclude'].nil? ? folder['rsync']['exclude'] : ['.vagrant/']

          devbox.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}",
            rsync__args: rsync_args, rsync__exclude: rsync_exclude, rsync__auto: rsync_auto, type: 'rsync', group: sync_group, owner: sync_owner
        else
          devbox.vm.synced_folder "#{folder['source']}", "#{folder['target']}", id: "#{i}",
            group: sync_group, owner: sync_owner, mount_options: ['dmode=775', 'fmode=764']
        end
      end
    end

    # VirtualBox configuration
    devbox.vm.provider :virtualbox do |virtualbox|
      data['vm']['provider']['virtualbox']['modifyvm'].each do |key, value|
        if key == 'memory'
          next
        end
        if key == 'cpus'
          next
        end

        if key == 'natdnshostresolver1'
          value = value ? 'on' : 'off'
        end

        virtualbox.customize ['modifyvm', :id, "--#{key}", "#{value}"]
      end

      virtualbox.customize ['modifyvm', :id, '--memory', "#{data['vm']['memory']}"]
      virtualbox.customize ['modifyvm', :id, '--cpus', "#{data['vm']['cpus']}"]

      if data['vm']['provider']['virtualbox']['modifyvm']['name'].nil? ||
        data['vm']['provider']['virtualbox']['modifyvm']['name'].empty?
        if data['vm']['hostname'].to_s.strip.length != 0
          virtualbox.customize ['modifyvm', :id, '--name', devbox.vm.hostname]
        end
      end
    end

    # Provider-specific configuration so you can fine-tune various
    # backing providers for Vagrant. These expose provider-specific options.
    # Example for VirtualBox:
    #
    devbox.vm.provider "virtualbox" do |vb|
      # Don't boot with headless mode
      # vb.gui = true

      # Use VBoxManage to customize the VM. For example to change memory:
      vb.customize ["modifyvm", :id, "--memory", "512"]
    end

    # Enable the Vagrant Cachier plugin if it's installed
    if Vagrant.has_plugin?('vagrant-cachier')
      config.cache.scope = :box
    end

    # Provisioning – run once
    # ====================================================================================================================
    # Initial provisioning. Installs all the necessary packages.
    devbox.vm.provision :shell, :path => "vagrant/initial-provision.sh"

    # Download and compile every configured PHP version
    data['multiphp'].each do |phpversion, values|
      if values['install'].to_i == 1
        devbox.vm.provision 'shell' do |s|
          s.path = 'vagrant/install-php.sh'
          s.args = [values['source_url'], "#{phpversion}", values['default'].to_i, values['hostname']]
        end
      end
    end

    # Download and compile XDebug for every configured PHP version
    data['multiphp'].each do |phpversion, values|
      if (values['install'].to_i == 1) && (values['xdebug_install'].to_i == 1)
        devbox.vm.provision 'shell' do |s|
          s.path = 'vagrant/install-xdebug.sh'
          s.args = [values['xdebug_url'], "#{phpversion}"]
        end
      end
    end

    # Install PEAR. This is a separate script as it uses GNU expect to run the installation
    devbox.vm.provision :shell, :path => "vagrant/install-pear.sh"

    # Install Composer, phpUnit, Phing, PHP CodeSniffer, PHP Mess Detector
    devbox.vm.provision :shell, :path => "vagrant/install-composer-and-friends.sh"

    # Download and install additional PHP scripts
    data['extrascripts'].each do |subdomain, values|
      if values['install'].to_i == 1
        devbox.vm.provision 'shell' do |s|
          s.path = 'vagrant/install-extrascript.sh'
          s.args = [values['source_url'], subdomain]
        end
      end
    end

    # Install all the Joomla! sites
    data['installsites'].each do |subdomain, values|
      devbox.vm.provision 'shell' do |s|
        s.path = 'vagrant/install-site-' + values['type'] + '.sh'
        s.args = [values['source'], subdomain]
      end

      if values['linkextensions'].to_i == 1
        data['extensions'].each do |tag, extval|
          if extval['type'] == 'relink'
            devbox.vm.provision 'shell' do |s|
              s.path = 'vagrant/link-joomla-extension.sh'
              s.args = [extval['source'], subdomain, tag]
            end
          end
          if extval['type'] == 'library'
            devbox.vm.provision 'shell' do |s|
              s.path = 'vagrant/link-joomla-library.sh'
              s.args = [extval['source'], extval['target'], subdomain]
            end
          end
        end
      end
    end

    # Install Mail Catcher
    devbox.vm.provision :shell, :path => "vagrant/install-mailcatcher.sh"

    # Set up host aliases for each PHP version and site
    if Vagrant.has_plugin?("vagrant-hostmanager")
      data['multiphp'].each do |phpversion, values|
        if values['install'].to_i == 1
          # Main domain
          devbox.hostmanager.aliases.push(values['hostname'])

          # Extra scripts' domains
          data['extrascripts'].each do |subdomain, extravalues|
            if extravalues['install'].to_i == 1
              devbox.hostmanager.aliases.push(subdomain + '.' + values['hostname'])
            end
          end

          # Joomla! site's domains
          data['installsites'].each do |subdomain, extravalues|
            devbox.hostmanager.aliases.push(subdomain + '.' + values['hostname'])
          end
        end
      end
    end


    # Provisioning – every time we spin up the box
    # ====================================================================================================================
    # Restart Apache. Makes sure that Apache can see directories added/mounted after the boot sequence.
    devbox.vm.provision "shell", inline: "service apache2 restart", run: "always"

    # Hosts file management
    if Vagrant.has_plugin?("vagrant-hostmanager")
      devbox.vm.provision :hostmanager
    end
  end
end

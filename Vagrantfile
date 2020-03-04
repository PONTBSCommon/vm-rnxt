# install plugins if not present.
required_plugins = %w( vagrant-disksize )

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"
  
  config.disksize.size = "65GB"
  # disable the default share. we won't use it.
  # share a git subfolder into the vagrant machine.
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "./git", "/home/vagrant/git", create: true
  config.vm.synced_folder "./scripts/dotfiles", "/home/vagrant/.dotfiles"
  config.vm.synced_folder "~/.m2/repository", "/home/vagrant/.m2/repository", create: true
  config.vm.synced_folder "~/.aws", "/home/vagrant/.aws", create: true
  
  # machine settings (virtualbox specific).
  config.vm.provider "virtualbox" do |vb|
    vb.name = "Roam Next Development Machine (vm-rnxt)"
    vb.memory = 6144 # 6GB RAM
    vb.cpus = 2 # 4 cores
  end

  #### PORT FORWARDING ####
  # these ports will appear on the host windows machine, allowing developers to work in intellij while taking advantage of services that
  # run as docker containers within the virtual machine
  config.vm.network "forwarded_port", guest: 15672, host: 15672, id: "rabbitmq"
  config.vm.network "forwarded_port", guest: 5671, host: 5671, id: "rabbitmq"
  config.vm.network "forwarded_port", guest: 5672, host: 5672, id: "rabbitmq"
  config.vm.network "forwarded_port", guest: 6379, host: 6379, id: "redis"
  config.vm.network "forwarded_port", guest: 3306, host: 3306, id: "mysql"
  config.vm.network "forwarded_port", guest: 4575, host: 4575, id: "localstack sns"
  config.vm.network "forwarded_port", guest: 4576, host: 4576, id: "localstack sqs"
  config.vm.network "forwarded_port", guest: 4577, host: 4577, id: "localstack web interface"
  config.vm.network "forwarded_port", guest: 3000, host: 3000, id: "angular ports"
  config.vm.network "forwarded_port", guest: 4200, host: 4200, id: "angular ports"
  config.vm.network "forwarded_port", guest: 5150, host: 5150, id: "angular ports"
  config.vm.network "forwarded_port", guest: 4444, host: 4444, id: "selenium"

  #### DEVELOPER SSH CERTS FOR GITHUB ACCESS ####
  # "borrow" the developer's github keys so that the virtual box can clone repositories from HP enterprise github
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
  config.vm.provision "file", source: "~/.ssh/known_hosts", destination: "/home/vagrant/.ssh/known_hosts"

  ### AUTHLY BINARY ###
  # this is a bit ugly - ideally, we would download this binary from https://github.azc.ext.hp.com/Public-Cloud-Core-Services/authly/releases during setup,
  # but their linux packaging appears to be broken, so we've temporarily opted to check the 1.10.0 linux x64 binary into this repository until they fix it
  config.vm.provision "file", source: "./bin/authly", destination: "/home/vagrant/bin/authly"

  ### FIRST RUN PROVISIONING SCRIPTS ###
  config.vm.provision "file", source: "./scripts/setup.sh", destination: "/home/vagrant/setup-win.sh"
  config.vm.provision "file", source: "./scripts/provision.sh", destination: "/home/vagrant/provision.sh"
  
  # the box is ready to go - execute the /scripts/provision.sh script on the box as root to continue
  config.vm.provision "shell", privileged: true, inline: <<-SCRIPT 
    apt-get install -qq dos2unix -y
    dos2unix /home/vagrant/provision.sh
    chmod +x /home/vagrant/provision.sh
    /home/vagrant/provision.sh
  SCRIPT
end
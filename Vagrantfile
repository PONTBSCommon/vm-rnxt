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
  config.vm.box = "bento/ubuntu-18.10"
  
  config.disksize.size = "50GB"
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
  config.vm.network "forwarded_port", guest: 15672, host: 15672, id: "rabbitmq"
  config.vm.network "forwarded_port", guest: 5671, host: 5671, id: "rabbitmq"
  config.vm.network "forwarded_port", guest: 5672, host: 5672, id: "rabbitmq"
  config.vm.network "forwarded_port", guest: 6379, host: 6379, id: "redis"
  config.vm.network "forwarded_port", guest: 3306, host: 3306, id: "mysql"
  config.vm.network "forwarded_port", guest: 4575, host: 4575, id: "localstack sns"
  config.vm.network "forwarded_port", guest: 4576, host: 4576, id: "localstack sqs"
  config.vm.network "forwarded_port", guest: 4577, host: 4577, id: "localstack web interface"


  #### VIRTUAL MACHINE CONFIGURATION FILES ####
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "/home/vagrant/.ssh/id_rsa"
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "/home/vagrant/.ssh/id_rsa.pub"
  config.vm.provision "file", source: "~/.ssh/known_hosts", destination: "/home/vagrant/.ssh/known_hosts"

  config.vm.provision "file", source: "./scripts/setup.sh", destination: "/home/vagrant/setup-win.sh"
  config.vm.provision "file", source: "./scripts/provision.sh", destination: "/home/vagrant/provision.sh"
  
  # bootstrap the setup.sh script in ~/.bashrc to run on first `vagrant ssh`.
  config.vm.provision "shell", privileged: true, inline: <<-SCRIPT 
    apt-get install -qq dos2unix -y
    dos2unix /home/vagrant/provision.sh
    dos2unix /home/vagrant/.dotfiles/versions.sh
    chmod +x /home/vagrant/provision.sh
    /home/vagrant/provision.sh
  SCRIPT
end
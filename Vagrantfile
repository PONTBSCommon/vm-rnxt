Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.10"
  config.disksize.size = "50GB"

  # disable the default share. we won't use it.
  # share a git subfolder into the vagrant machine.
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.synced_folder "./git", "/home/vagrant/git/", create: true
  config.vm.synced_folder "./scripts/dotfiles", "/home/vagrant/.dotfiles/"
  
  # machine settings (virtualbox specific).
	config.vm.provider "virtualbox" do
    memory = 6144 # 6GB RAM
    cpus = 4 # 4 cores
  end

  # first-boot config trigger
  config.trigger.before :up do
    run = "./scripts/local.ps1"
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
  config.vm.provision "file", source: "~/.aws/credentials", destination: "/home/vagrant/.aws/credentials"
  config.vm.provision "file", source: "~/.aws/config", destination: "/home/vagrant/.aws/config"
  config.vm.provision "file", source: "~/.m2/settings.xml", destination: "/home/vagrant/.m2/settings.xml"
  config.vm.provision "file", source: "./scripts/setup.sh", destination: "/home/vagrant/setup-win.sh"
  
  # bootstrap the setup.sh script in ~/.bashrc to run on first `vagrant ssh`.
  config.vm.provision "shell", path: "./scripts/provision.sh"
end
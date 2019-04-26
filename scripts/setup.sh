source ~/.dotfiles/funcs.sh

logf 'update apt sources, install updates'
echo -e "vagrant\n" | sudo --stdin apt-get update -q


logf 'hold back packages that break auto-install. (or in grubs case, just break.)'
sudo apt-mark hold console-setup console-setup-linux grub-common grub-pc grub-pc-bin grub2-common keyboard-configuration


logf 'update system. (quietly `shh`) '
DEBIAN_FRONTEND=noninteractive
TERM=xterm
sudo apt-get upgrade -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"


logf ' ¯\_(ツ)_/¯ install things that dont get installed properly in wander-devbox ¯\_(ツ)_/¯'
sudo apt install awscli maven -y -qq
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
sudo mv kops-linux-and64 /usr/local/bin/kops

logf 'set permissions on copied in ssh keys.'
sudo chmod 700 /home/vagrant/.ssh
sudo chmod 644 /home/vagrant/.ssh/known_hosts
sudo chmod 600 /home/vagrant/.ssh/id_rsa
sudo chmod 644 /home/vagrant/.ssh/id_rsa.pub


logf 'Pull down the base wander projects.'

mkdir ~/git/ops && cd ~/git/ops
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git devbox
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd

mkdir ~/git/wander && cd ~/git/wander
git clone git@github.azc.ext.hp.com:Wander/wander-common.git common
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test


logf 'run the wander devbox script to install their tools.'
cd ~/git/ops/devbox && ./build.sh


logf 'if you dont have aws setup locally run aws configure on first boot to get your creds.'
if [ ! -f /home/vagrant/.aws/credentials ]; then 
  logf 'setup connection to wander / s3 artifacts'
  aws configure
else
  logf 'skipping `aws configure` aws config present from host'
fi


logf 'install common maven dependencies.'
source ~/.dotfiles/config.sh

cd ~/git/wander/common
mvn clean
cd ~/git/wander/e2e-test
mvn clean
cd ~


logf 'setup complete, `exit`, then `vagrant reload` to complete setup'
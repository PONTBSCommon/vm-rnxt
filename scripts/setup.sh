source ~/.dotfiles/funcs.sh

logf 'update system. (quietly `shh`) '
DEBIAN_FRONTEND=noninteractive
TERM=xterm
sudo apt-mark hold console-setup console-setup-linux grub-common grub-pc grub-pc-bin grub2-common keyboard-configuration
sudo apt-get upgrade -y -q -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
sudo apt-get autoremove -y


logf 'installing java 11 and maven'
sudo apt install openjdk-11-jdk maven


logf 'installing docker'
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker vagrant


logf 'install docker-compose'
curl -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


logf 'install awscli'
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o /usr/local/src/awscli-bundle.zip
unzip /usr/local/src/awscli-bundle.zip
sudo /usr/local/src/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws


logf 'install kops'
curl -L https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 -o /usr/local/bin/kops
sudo chmod +x /usr/local/bin/kops


logf 'install oh-my-bash (pretty git prompt)'
sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)"
cat ~/.bashrc >> ~/.bashrc.pre-oh-my-bash
mv ~/.bashrc.pre-oh-my-bash ~/.bashrc -f


logf 'setup aws credentials'
if [ ! -f /home/vagrant/.aws/credentials ]; then 
  logf 'setting up aws credentials manually'
  aws configure
else
  logf 'aws config present on host.'
fi



logf 'set permissions on copied in ssh keys.'
sudo chmod 700 /home/vagrant/.ssh \
&& sudo chmod 644 /home/vagrant/.ssh/known_hosts \
&& sudo chmod 600 /home/vagrant/.ssh/id_rsa \
&& sudo chmod 644 /home/vagrant/.ssh/id_rsa.pub \
&& echo 'done.'


logf 'Pull down the base wander projects.'
mkdir ~/git/ops && cd ~/git/ops && \
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts && \
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd && \
echo 'devops projects done.'

mkdir ~/git/wander && cd ~/git/wander && \
git clone git@github.azc.ext.hp.com:Wander/wander-common.git common && \
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test && \
echo 'common projects done.'


logf 'install common maven dependencies.'
source ~/.dotfiles/config.sh

cd ~/git/wander/common && mvn clean
cd ~/git/wander/e2e-test && mvn clean
cd ~

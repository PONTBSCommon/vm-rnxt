source ~/.dotfiles/funcs.sh

logf 'update system. (quietly `shh`) '
DEBIAN_FRONTEND=noninteractive
TERM=xterm
sudo apt-mark hold console-setup console-setup-linux grub-common grub-pc grub-pc-bin grub2-common keyboard-configuration -qq
sudo apt-get update
sudo apt-get upgrade -yq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
sudo apt-get autoremove  -yq


logf 'installing docker'
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -yq && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
sudo apt-get update && \
sudo apt-get install docker-ce docker-ce-cli containerd.io -yq && \
sudo usermod -aG docker vagrant && \
echo 'done.'


logf 'take ownership of the /usr/local/ folder.'
sudo chown vagrant:vagrant /usr/local/ -R && \
sudo chmod +rwx /usr/local/ -R && \
echo 'done.'


logf 'installing java 11'
curl -L https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_linux-x64_bin.tar.gz -o /tmp/openjdk-11.28.tar.gz && \
tar xvf /tmp/openjdk-11.28.tar.gz -C /usr/local/ && \
mv /usr/local/jdk-11/ /usr/local/openjdk-11.28/ && \
echo 'done.'


logf 'installing maven'
curl -L http://apache.mirror.gtcomm.net/maven/maven-3/3.6.1/binaries/apache-maven-3.6.1-bin.tar.gz -o /tmp/apache-maven-3.6.1-bin.tar.gz && \
tar xvf /tmp/apache-maven-3.6.1-bin.tar.gz -C /usr/local/ && \
ln -s /usr/local/apache-maven-3.6.1/bin/mvn /usr/local/bin/mvn && \
echo 'done.'


logf 'install docker-compose'
curl -L https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && \
sudo chmod +x /usr/local/bin/docker-compose && \
echo 'done.'


logf 'install awscli'
sudo apt install unzip python -yq && \
sudo curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o /tmp/awscli-bundle.zip && \
sudo unzip /tmp/awscli-bundle.zip -d /tmp/ && \
sudo /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
echo 'done.'


logf 'install kops'
curl -L https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 -o /usr/local/bin/kops && \
sudo chmod +x /usr/local/bin/kops && \
echo 'done.'


logf 'install oh-my-bash (pretty git prompt)'
sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)" &
echo 'done.'


logf 'set permissions on copied in ssh keys.'
sudo chmod 700 /home/vagrant/.ssh && \
sudo chmod 644 /home/vagrant/.ssh/known_hosts && \
sudo chmod 600 /home/vagrant/.ssh/id_rsa && \
sudo chmod 644 /home/vagrant/.ssh/id_rsa.pub && \
echo 'done.'


logf 'Pull down the base wander projects.'
mkdir ~/git/ops && cd ~/git/ops && \
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts && \
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd && \
echo 'devops projects done.'

mkdir ~/git/wander && cd ~/git/wander && \
git clone git@github.azc.ext.hp.com:Wander/wander-common.git common && \
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test && \
echo 'common projects done.'


logf 'add printeron nameservers'
sudo apt install resolvconf -yq && \
echo 'nameserver 172.16.200.10
nameserver 172.16.200.12' | sudo tee -a /etc/resolvconf/resolv.conf.d/head && \
sudo resolvconf -u && \
echo 'done.'


logf 'install common maven dependencies.'
source ~/.dotfiles/config.sh && \
cd ~/git/wander/common && mvn clean && \
cd ~/git/wander/e2e-test && mvn clean && \
echo 'done.'


logf 'final configuration for ~/.bashrc with oh-my-bash'
cat ~/.bashrc >> ~/.bashrc.pre-oh-my-bash && \
mv ~/.bashrc.pre-oh-my-bash ~/.bashrc -f && \
source ~/.bashrc && \
cd ~

logf '~(˘▾˘~) Installation is complete. Logout and Back In To Complete Setup. Happy coding! (~˘▾˘)~'
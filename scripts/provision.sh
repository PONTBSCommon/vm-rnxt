#############################################
## #         Configure Settings          # ##
#############################################

# functions used only here
echo_success() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39mdone. \e[32m(success)\e[39m"; }
echo_failure() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39merror \e[31m(failure)\e[39m"; }
logf() { echo -e "\n\e[93m[$(date +"%H:%M:%S:%4N")]\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }


# import software versions.
source /home/vagrant/.dotfiles/versions.sh

export DEBIAN_FRONTEND=noninteractive
export TERM=xterm

# fix datetime.
logf 'set proper timezone'
apt-get -qq install ifupdown >/dev/null && \
timedatectl set-timezone America/Toronto && \
echo_success || echo_failure 

# install line ending convertor.
logf 'installing dos2unix line ending convertor'
apt-get -qq install dos2unix >/dev/null && \
echo_success || echo_failure

# convert setup script to unix line endings.
tr -d '\15\32' < /home/vagrant/setup-win.sh > /home/vagrant/setup.sh && rm /home/vagrant/setup-win.sh

# open ownership of the .aws folder
logf 'set permissions on shared files and folders'
chmod 777 /home/vagrant/.aws -R && chown vagrant:vagrant /home/vagrant/.aws -R && \
chmod 777 /home/vagrant/setup.sh && chown vagrant:vagrant /home/vagrant/setup.sh && \
echo_success || echo_failure
# add custom profile my_bashrc.sh to bashrc
logf 'add custom profile to ~/.bashrc'
echo '
for file in $(ls ~/.dotfiles); do dos2unix ~/.dotfiles/$file >/dev/null; done
for file in $(ls ~/.aws); do dos2unix ~/.aws/$file >/dev/null; done 
source /home/vagrant/.dotfiles/my_bashrc.sh
' >> /home/vagrant/.bashrc &&
echo_success || echo_failure


#############################################
## # System setup, and tool installation # ##
#############################################
# logf 'update system. (quietly `shh`)'
# printf 'holding back packages that cant be updated...' && \
# apt-mark hold console-setup console-setup-linux grub-common grub-pc grub-pc-bin grub2-common keyboard-configuration >/dev/null && \
printf 'updating package lists...' && \
apt-get -q update >/dev/null #&& \
# printf 'updating system (this will take a few minutes)...' && \
# apt-get -qq upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >/dev/null && \
# printf 'removing unused packages...' && \
# apt-get -qq autoremove -y >/dev/null && \
# echo_success || echo_failure 


logf 'add printeron nameservers'
apt-get -qq install -y resolvconf ifupdown >/dev/null && \
echo -e "nameserver 172.16.200.10\nnameserver 172.16.200.12" >> /etc/resolvconf/resolv.conf.d/head && \
resolvconf -u && \
echo_success || echo_failure 


logf '[00] installing docker'
apt-get -qq install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common >/dev/null && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >/dev/null && \
apt-get -qq update >/dev/null && \
apt-get -qq install -y docker-ce docker-ce-cli containerd.io >/dev/null && \
usermod -aG docker vagrant >/dev/null && \
systemctl enable docker && \
echo_success || echo_failure 


logf "[01] installing java $JDK_VER"
curl -sSL "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-${JDK_VER}_linux-x64_bin.tar.gz" -o "/tmp/openjdk-${JDK_VER}.tar.gz" && \
curl -sSL "https://download.java.net/java/GA/jdk11/9/GPL/openjdk-${JDK_VER}_linux-x64_bin.tar.gz.sha256" -o /tmp/sha256 && \
sha256sum -t /tmp/sha256 "/tmp/openjdk-${JDK_VER}.tar.gz" && rm /tmp/sha256 && \
tar xvf "/tmp/openjdk-${JDK_VER}.tar.gz" -C /usr/local/ 1>/dev/null && \
mv "/usr/local/jdk-${JDK_VER}/" "/usr/local/openjdk-${JDK_VER}/" && \
echo_success || echo_failure 


logf "[02] installing maven $MVN_VER"
curl -sSL "http://apache.mirror.gtcomm.net/maven/maven-3/${MVN_VER}/binaries/apache-maven-${MVN_VER}-bin.tar.gz" -o "/tmp/apache-maven-${MVN_VER}-bin.tar.gz" && \
curl -sSL "http://apache.mirror.gtcomm.net/maven/maven-3/${MVN_VER}/binaries/apache-maven-${MVN_VER}-bin.tar.gz.sha512" -o /tmp/sha512 && \
sha512sum -t /tmp/sha512 "/tmp/apache-maven-${MVN_VER}-bin.tar.gz" && rm /tmp/sha512 && \
tar xvf "/tmp/apache-maven-${MVN_VER}-bin.tar.gz" -C /usr/local/ 1>/dev/null && \
ln -s "/usr/local/apache-maven-${MVN_VER}/bin/mvn" "/usr/local/bin/mvn" && \
echo_success || echo_failure 


logf "[03] install docker-compose $COMPOSE_VER"
curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
curl -sSL "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m).sha256" -o /tmp/sha256 && \
sha256sum -t /tmp/sha256 /usr/local/bin/docker-compose && rm /tmp/sha256 && \
chmod +x /usr/local/bin/docker-compose && \
echo_success || echo_failure 


logf '[04] install awscli'
apt-get -qq install unzip python -y >/dev/null && \
curl -sS "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o /tmp/awscli-bundle.zip && \
unzip /tmp/awscli-bundle.zip -d /tmp/ 1>/dev/null && \
/tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws >/dev/null && \
echo_success || echo_failure 


logf "[05] install kops $KOPS_VER"
curl -sSL https://github.com/kubernetes/kops/releases/download/$KOPS_VER/kops-linux-amd64 -o /usr/local/bin/kops && \
chmod +x /usr/local/bin/kops && \
echo_success || echo_failure 


logf "[06] install kubernetes kubectl $KUBECTL_VER"
curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && \
apt-get -qq update >/dev/null && \
apt-get install --no-install-recommends --allow-downgrades -y kubectl=$KUBECTL_VER jq >/dev/null 
echo_success || echo_failure 


logf "[07] install helm/tiller $HELM_VER"
curl -sS https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh && \
chmod +x get_helm.sh && \
./get_helm.sh --version "v${HELM_VER}" >/dev/null && \
rm -f get_helm.sh && \
echo_success || echo_failure 


logf '[08] install oh-my-bash (pretty git prompt)'
sudo -Hu vagrant sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)" <<< 'exit' && \
cat /home/vagrant/.bashrc >> /home/vagrant/.bashrc.pre-oh-my-bash && \
mv /home/vagrant/.bashrc.pre-oh-my-bash /home/vagrant/.bashrc -f && \
echo_success || echo_failure 

logf "[10] install nodejs $NODE_VER"
curl -sS https://nodejs.org/dist/v${NODE_VER}/SHASUMS256.txt.asc -o /tmp/sha256 && \
curl -sS https://nodejs.org/dist/v${NODE_VER}/node-v${NODE_VER}-linux-x64.tar.xz -o /tmp/node-v${NODE_VER} && \
sha256sum -t /tmp/sha256 /tmp/node-v${NODE_VER} && rm /tmp/sha256 && \
tar -xvf /tmp/node-v${NODE_VER} -C /usr/local && \
rm -rf /tmp/node-v${NODE_VER} && \
rm -rf /tmp/sha256 &&\
echo_success || echo_failure

logf "[11] install google chrome driver for nodejs testing."
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list && \
sudo apt-get -qq update -y && \
sudo apt-get -qq install google-chrome-stable -y && \
echo_success || echo_failure

logf "[12] install python 2.7's pip and yaml parser yq"
curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
python /tmp/get-pip.py && \
pip install yq && \
echo_success || echo_failure

logf 'set permissions on copied in ssh keys.'
chmod 700 /home/vagrant/.ssh && \
chmod 644 /home/vagrant/.ssh/known_hosts && \
chmod 600 /home/vagrant/.ssh/id_rsa && \
chmod 644 /home/vagrant/.ssh/id_rsa.pub && \
echo_success || echo_failure 

logf 'clear git folder'
rm -rf /home/vagrant/git/* && \
echo_success || echo_failure

logf 'take ownership of the /usr/local/ folder.'
chown vagrant:vagrant /usr/local/ -R && \
chmod +rwx /usr/local/ -R && \
echo_success || echo_failure 

logf 'let vagrant user sudo without password'
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
echo_success || echo_failure 

logf 'clean up /tmp'
rm -rf /tmp/* && \
echo_success || echo_failure
source ~/.dotfiles/funcs.sh
source ~/.dotfiles/versions.sh

ssh_setup=false && logf 'set permissions on copied in ssh keys.'
sudo chmod 700 /home/vagrant/.ssh && \
sudo chmod 644 /home/vagrant/.ssh/known_hosts && \
sudo chmod 600 /home/vagrant/.ssh/id_rsa && \
sudo chmod 644 /home/vagrant/.ssh/id_rsa.pub && \
echo_success && ssh_setup=true


own_usr_local=false && logf 'take ownership of the /usr/local/ folder.'
sudo chown vagrant:vagrant /usr/local/ -R && \
sudo chmod +rwx /usr/local/ -R && \
echo_success && own_usr_local=true


system_update=false && logf 'update system. (quietly `shh`)'
DEBIAN_FRONTEND=noninteractive && \
TERM=xterm && \
sudo apt-mark hold console-setup console-setup-linux grub-common grub-pc grub-pc-bin grub2-common keyboard-configuration && \
sudo apt-get -qq update && \
sudo apt-get -qq upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" && \
sudo apt-get -qq autoremove -y && \
echo_success && system_update=true

set_timezone=false && logf 'set proper timezone'
echo "America/Toronto" | sudo tee /etc/timezone && \
sudo dpkg-reconfigure --frontend noninteractive tzdata && \
echo_success && set_timezone=true


pon_nameserver=false && logf 'add printeron nameservers'
sudo apt-get -qq install -y resolvconf && \
echo -e "nameserver 172.16.200.10\nnameserver 172.16.200.12" | sudo tee -a /etc/resolvconf/resolv.conf.d/head && \
sudo service resolvconf restart && \
echo_success && pon_nameserver=true


inst_docker=false && logf '[00] installing docker'
sudo apt-get -qq install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
sudo apt-get -qq update && \
sudo apt-get -qq install -y docker-ce docker-ce-cli containerd.io && \
sudo usermod -aG docker vagrant && \
echo_success && inst_docker=true


inst_java=false && logf "[01] installing java ${JDK_VER}+${JDK_REV}"
curl -L "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-${JDK_VER}%2B${JDK_REV}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK_VER}_${JDK_REV}.tar.gz" -o "/tmp/openjdk-${JDK_VER}.tar.gz" && \
curl -L "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-${JDK_VER}%2B${JDK_REV}/OpenJDK11U-jdk_x64_linux_hotspot_${JDK_VER}_${JDK_REV}.tar.gz.sha256.txt" -o /tmp/sha256 && \
sha256sum -t /tmp/sha256 "/tmp/openjdk-${JDK_VER}.tar.gz" && rm /tmp/sha256 && \
tar xvf "/tmp/openjdk-${JDK_VER}.tar.gz" -C /usr/local/ 1>/dev/null && \
mv "/usr/local/jdk-${JDK_VER}+${JDK_REV}/" "/usr/local/openjdk-${JDK_VER}/" && \
echo_success && inst_java=true


inst_maven=false && logf "[02] installing maven $MVN_VER"
curl -L "http://apache.mirror.gtcomm.net/maven/maven-3/${MVN_VER}/binaries/apache-maven-${MVN_VER}-bin.tar.gz" -o "/tmp/apache-maven-${MVN_VER}-bin.tar.gz" && \
curl -L "http://apache.mirror.gtcomm.net/maven/maven-3/${MVN_VER}/binaries/apache-maven-${MVN_VER}-bin.tar.gz.sha512" -o /tmp/sha512 && \
sha512sum -t /tmp/sha512 "/tmp/apache-maven-${MVN_VER}-bin.tar.gz" && rm /tmp/sha512 && \
tar xvf "/tmp/apache-maven-${MVN_VER}-bin.tar.gz" -C /usr/local/ 1>/dev/null && \
ln -s "/usr/local/apache-maven-${MVN_VER}/bin/mvn" "/usr/local/bin/mvn" && \
echo_success && inst_maven=true


inst_compose=false && logf "[03] install docker-compose $COMPOSE_VER"
curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m).sha256" -o /tmp/sha256 && \
sha256sum -t /tmp/sha256 /usr/local/bin/docker-compose && rm /tmp/sha256 && \
sudo chmod +x /usr/local/bin/docker-compose && \
echo_success && inst_compose=true


inst_awscli=false && logf '[04] install awscli'
sudo apt-get -qq install unzip python -y && \
sudo curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o /tmp/awscli-bundle.zip && \
sudo unzip /tmp/awscli-bundle.zip -d /tmp/ 1>/dev/null && \
sudo /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && \
echo_success && inst_awscli=true


inst_kops=false && logf '[05] install kops'
curl -L https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64 -o /usr/local/bin/kops && \
sudo chmod +x /usr/local/bin/kops && \
echo_success && inst_kops=true


inst_kubectl=false && logf '[06] install kubernetes kubectl'
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
sudo apt-get -qq update && \
sudo apt-get -qq install -y kubectl jq && \
echo_success && inst_kubectl=true


inst_helm=false && logf '[07] install helm/tiller'
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh && \
chmod +x get_helm.sh && \
./get_helm.sh && \
rm -f get_helm.sh && \
echo_success && inst_helm=true


inst_omb=false && logf '[08] install oh-my-bash (pretty git prompt)'
sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)" <<< 'exit' && \
cat ~/.bashrc >> ~/.bashrc.pre-oh-my-bash && \
mv ~/.bashrc.pre-oh-my-bash ~/.bashrc -f && \
source ~/.bashrc && \
echo_success && inst_omb=true


pull_ops=false && logf 'Pull down the base wander projects.'
mkdir ~/git/ops && cd ~/git/ops && \
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts && \
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd && \
echo_success && pull_ops=true

echo -e '\n'

pull_wander=false && mkdir ~/git/wander && cd ~/git/wander && \
git clone git@github.azc.ext.hp.com:Wander/wander-common.git common && \
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test && \
echo_success && pull_wander=true


mvn_clean=false && logf 'install common maven dependencies.'
source ~/.bashrc && \
cd ~/git/wander/common && mvn clean && \
cd ~/git/wander/e2e-test && mvn clean && \
echo_success && mvn_clean=true

logf 'Operations Summary'
printf "%-50s => %s\n" "Set Permissions On Imported SSH Keys" `status_bool $ssh_setup`
printf "%-50s => %s\n" "Take Ownership Of The /usr/local Directory" `status_bool $own_usr_local`
printf "%-50s => %s\n" "Update The System" `status_bool $system_update`
printf "%-50s => %s\n" "Set The Timezone To America/Toronto" `status_bool $set_timezone`
printf "%-50s => %s\n" "Add The Printeron Nameservers" `status_bool $pon_nameserver`
printf "%-50s => %s\n" "Install AWS CLI" `status_bool $inst_awscli`
printf "%-50s => %s\n" "Install Docker Compose" `status_bool $inst_compose`
printf "%-50s => %s\n" "Install Docker" `status_bool $inst_docker`
printf "%-50s => %s\n" "Install Helm & Tiller" `status_bool $inst_helm`
printf "%-50s => %s\n" "Install Java ${JDK_VER}" `status_bool $inst_java`
printf "%-50s => %s\n" "Install Kops" `status_bool $inst_kops`
printf "%-50s => %s\n" "Install KubeCTL" `status_bool $inst_kubectl`
printf "%-50s => %s\n" "Install Maven ${MVN_VER}" `status_bool $inst_maven`
printf "%-50s => %s\n" "Install Oh My Bash" `status_bool $inst_omb`
printf "%-50s => %s\n" "Pull Wander DevOps Repos" `status_bool $pull_ops`
printf "%-50s => %s\n" "Pull Wander Service Repos" `status_bool $pull_wander`
printf "%-50s => %s\n" "Install Wander Common Dependencies" `status_bool $mvn_clean`

cd ~ && logf '~(˘▾˘~) Installation is complete. Logout and Back In To Complete Setup. Happy coding! (~˘▾˘)~'
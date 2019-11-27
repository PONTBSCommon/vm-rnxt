#############################################
## #         Configure Settings          # ##
#############################################

# functions used only here
echo_success() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39mdone. \e[32m(success)\e[39m"; }
echo_failure() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39merror \e[31m(failure)\e[39m"; }
logf() { echo -e "\n\e[93m[$(date +"%H:%M:%S:%4N")]\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

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

logf 'take ownership of the /usr/local/ folder.'
chown vagrant:vagrant /usr/local/ -R && \
chmod +rwx /usr/local/ -R && \
echo_success || echo_failure 

logf 'let vagrant user sudo without password'
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
echo_success || echo_failure 

#############################################
## # System setup, and tool installation # ##
#############################################
printf 'updating package lists...' && \
apt-get -q update >/dev/null #&& \
printf 'updating system (this will take a few minutes)...' && \
apt-get -qq upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >/dev/null && \
printf 'removing unused packages...' && \
apt-get -qq autoremove -y >/dev/null && \
echo_success || echo_failure 

logf '[01] add printeron nameservers'
apt-get -qq install -y resolvconf ifupdown >/dev/null && \
echo -e "nameserver 172.16.200.10\nnameserver 172.16.200.12" >> /etc/resolvconf/resolv.conf.d/head && \
resolvconf -u && \
echo_success || echo_failure 

logf '[02] set permissions on copied in ssh keys.'
chmod 700 /home/vagrant/.ssh && \
chmod 644 /home/vagrant/.ssh/known_hosts && \
chmod 600 /home/vagrant/.ssh/id_rsa && \
chmod 644 /home/vagrant/.ssh/id_rsa.pub && \
echo_success || echo_failure 

MD5=$(ssh-keygen -l -E md5 -f /home/vagrant/.ssh/id_rsa.pub)
printf 'the MD5 hash of your public key is %s' "$MD5"

logf '[03] install oh-my-bash (pretty git prompt)'
sudo -Hu vagrant sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)" <<< 'exit' && \
cat /home/vagrant/.bashrc >> /home/vagrant/.bashrc.pre-oh-my-bash && \
mv /home/vagrant/.bashrc.pre-oh-my-bash /home/vagrant/.bashrc -f && \
echo_success || echo_failure

logf '[04] clean up /tmp'
rm -rf /tmp/* && \
echo_success || echo_failure

logf 'Initial setup is complete. Additional setup steps will run the first time that you log into the box'
logf 'Please run `vagrant ssh` to complete the installation process'
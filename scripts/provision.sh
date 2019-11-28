# this script runs as root after the box boots for the first time
# its goal is to apply any available updates to the base box, configure some permissions, and set up the .bashrc script for the vagrant user

# functions used only here
echo_success() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39mdone. \e[32m(success)\e[39m"; }
echo_failure() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39merror \e[31m(failure)\e[39m"; }
logf() { echo -e "\n\e[93m[$(date +"%H:%M:%S:%4N")]\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

export DEBIAN_FRONTEND=noninteractive
export TERM=xterm

# fix datetime.
logf '[01/19] set proper timezone'
apt-get -qq install ifupdown >/dev/null && \
timedatectl set-timezone America/Toronto && \
echo_success || echo_failure 

# install line ending convertor.
logf '[02/19] installing dos2unix line ending convertor'
apt-get -qq install dos2unix >/dev/null && \
echo_success || echo_failure

# convert setup script to unix line endings.
tr -d '\15\32' < /home/vagrant/setup-win.sh > /home/vagrant/setup.sh && rm /home/vagrant/setup-win.sh

# open ownership of the .aws folder
logf '[03/19] set permissions on shared files and folders'
chmod 777 /home/vagrant/.aws -R && chown vagrant:vagrant /home/vagrant/.aws -R && \
chmod 777 /home/vagrant/setup.sh && chown vagrant:vagrant /home/vagrant/setup.sh && \
echo_success || echo_failure

# add custom profile my_bashrc.sh to bashrc
# this configures the vagrant user's shell whenever they log in and bootstraps the setup.sh script to run the first time 
# the vagrant user logs into the box with `vagrant ssh`
logf '[04/19] add custom profile to ~/.bashrc'
echo '
for file in $(ls ~/.dotfiles); do dos2unix ~/.dotfiles/$file >/dev/null; done
for file in $(ls ~/.aws); do dos2unix ~/.aws/$file >/dev/null; done 
source /home/vagrant/.dotfiles/my_bashrc.sh
' >> /home/vagrant/.bashrc &&
echo_success || echo_failure

logf '[05/19] take ownership of the /usr/local/ folder.'
chown vagrant:vagrant /usr/local/ -R && \
chmod +rwx /usr/local/ -R && \
echo_success || echo_failure 

# since this is just a development box, sudo just protects the vagrant user from themselves, so we may as well make it convenient to use
logf '[06/19] let vagrant user sudo without password'
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
echo_success || echo_failure 

# the authly binary needs to be executable by any user from anywhere on the box
logf '[07/19] add authly to $PATH'
sudo cp /home/vagrant/bin/authly /usr/local/bin/authly && \
sudo chmod 755 /usr/local/bin/authly && \
echo_success || echo_failure

# later on, we'll install docker on the box. By default, it can only be used by the root user, but the vagrant user needs it too
# see https://docs.docker.com/install/linux/linux-postinstall/ for details
logf '[08/19] give vagrant permission to use docker'
sudo groupadd docker && \
sudo usermod -aG docker vagrant && \
echo_success || echo_failure

# apply any available updates to the box and remove any packages that are no longer required
logf '[09/19] updating the system'
apt-get -q update >/dev/null && \
apt-get -qq upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >/dev/null && \
apt-get -qq autoremove -y >/dev/null && \
echo_success || echo_failure 

# not sure if this is still required, but it should let the box get at the \\print share drive and PrinterOn Confluence
logf '[10/19] add printeron nameservers'
apt-get -qq install -y resolvconf ifupdown >/dev/null && \
echo -e "nameserver 172.16.200.10\nnameserver 172.16.200.12" >> /etc/resolvconf/resolv.conf.d/head && \
resolvconf -u && \
echo_success || echo_failure 

# git is really picky about the permissions on ssh keys that it uses to authenticate with
logf '[11/19] set permissions on copied in ssh keys'
chmod 700 /home/vagrant/.ssh && \
chmod 644 /home/vagrant/.ssh/known_hosts && \
chmod 600 /home/vagrant/.ssh/id_rsa && \
chmod 644 /home/vagrant/.ssh/id_rsa.pub && \
echo_success || echo_failure 

MD5=$(ssh-keygen -l -E md5 -f /home/vagrant/.ssh/id_rsa.pub)
printf 'the MD5 hash of your public github key is %s' "$MD5"

# the bash terminal is kind of ugly. this package makes it a little more bearable
logf '[12/19] install oh-my-bash (pretty git prompt)'
sudo -Hu vagrant sh -c "$(curl -fsSL https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh)" <<< 'exit' && \
cat /home/vagrant/.bashrc >> /home/vagrant/.bashrc.pre-oh-my-bash && \
mv /home/vagrant/.bashrc.pre-oh-my-bash /home/vagrant/.bashrc -f && \
echo_success || echo_failure

logf '[13/19] clean up /tmp'
rm -rf /tmp/* && \
echo_success || echo_failure

logf 'Initial setup is complete. Additional setup steps will run the first time that you log into the box'
logf 'Please run `vagrant ssh` to complete the installation process'
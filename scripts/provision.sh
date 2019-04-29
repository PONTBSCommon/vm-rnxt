chmod 777 /home/vagrant/.aws -R

tr -d '\15\32' < /home/vagrant/setup-win.sh > /home/vagrant/setup.sh
tr -d '\15\32' < /home/vagrant/settings-win.xml > /home/vagrant/.m2/settings.xml

# convertor for line endings.
apt-get -qq install -y dos2unix

# remove backup files with windows /r returns.
rm /home/vagrant/setup-win.sh

# make setup script executable
chmod +x /home/vagrant/setup.sh

# source the synced dotfiles.
echo '
find /home/vagrant/.dotfiles/ -type f -print0 | xargs -0 dos2unix
find /home/vagrant/.aws/ -type f -print0 | xargs -0 dos2unix
source ~/.dotfiles/my_bashrc
' >> /home/vagrant/.bashrc

# bootstrap the setup script.
echo 'if [ -f /home/vagrant/setup.sh ]; then 
  # run first setup
  rm /home/vagrant/git/install.log 2>/dev/null
  /home/vagrant/setup.sh | tee /home/vagrant/git/install.log
  sudo rm /home/vagrant/setup.sh
fi' >> /home/vagrant/.bashrc

# convert all line endings

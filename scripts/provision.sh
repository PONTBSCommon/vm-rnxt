chmod 777 /home/vagrant/.aws -R

tr -d '\15\32' < /home/vagrant/setup-win.sh > /home/vagrant/setup.sh

# remove backup files with windows /r returns.
rm /home/vagrant/setup-win.sh

# make setup script executable
chmod +x /home/vagrant/setup.sh

# source the synced dotfiles.
echo 'for f in ~/.dotfiles/*; do source $f; done' >> /home/vagrant/.bashrc

# bootstrap the setup script.
echo 'if [ -f /home/vagrant/setup.sh ]; then 
  # run first setup
  /home/vagrant/setup.sh | tee /home/vagrant/git/install.log
  sudo rm /home/vagrant/setup.sh
fi' >> /home/vagrant/.bashrc
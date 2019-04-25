chmod 777 /home/vagrant/.aws -R

tr -d '\15\32' < /home/vagrant/setup-win.sh > /home/vagrant/setup.sh
tr -d '\15\32' < /home/vagrant/funcs-win.sh > /home/vagrant/.funcs.sh

# remove backup files with windows /r returns.
rm /home/vagrant/setup-win.sh
rm /home/vagrant/funcs-win.sh

# make setup script executable
chmod +x /home/vagrant/setup.sh

# set permissions on copied in ssh keys.
chmod 700 /home/vagrant/.ssh
chmod 644 /home/vagrant/.ssh/known_hosts
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 644 /home/vagrant/.ssh/id_rsa.pub

chown vagrant:vagrant /home/vagrant/.ssh -R

# add the helper functions file.
echo 'source /home/vagrant/.funcs.sh' >> /home/vagrant/.bashrc

# bootstrap the setup script.
echo 'if [ -f /home/vagrant/setup.sh ]; then 
  echo -e "vagrant\n" | sudo --stdin /home/vagrant/setup.sh
  sudo rm /home/vagrant/setup.sh
fi' >> /home/vagrant/.bashrc
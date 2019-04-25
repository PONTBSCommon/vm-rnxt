chmod 777 /home/vagrant/.aws -R

tr -d '\15\32' < /home/vagrant/setup-win.sh > /home/vagrant/setup.sh

rm /home/vagrant/setup-win.sh
chmod +x /home/vagrant/setup.sh

# set permissions on copied in ssh keys.
chmod 700 /home/vagrant/.ssh
chmod 644 /home/vagrant/.ssh/known_hosts
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 644 /home/vagrant/.ssh/id_rsa.pub

chown vagrant:vagrant /home/vagrant/.ssh -R

echo 'if [ -f /home/vagrant/setup.sh ]; then 
  echo -e "vagrant\n" | sudo --stdin /home/vagrant/setup.sh
  sudo rm /home/vagrant/setup.sh
fi' >> /home/vagrant/.bashrc
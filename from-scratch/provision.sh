chmod 777 /home/vagrant/.aws -R

tr -d '\15\32' < /home/vagrant/setup-win.sh > /home/vagrant/setup.sh

rm /home/vagrant/setup-win.sh
chmod +x /home/vagrant/setup.sh

chmod 644 /home/vagrant/.ssh -R
chown vagrant:vagrant /home/vagrant/.ssh -R

echo 'if [ -f /home/vagrant/setup.sh ]; then 
  /home/vagrant/setup.sh
  rm /home/vagrant/setup.sh
fi' >> /home/vagrant/.bashrc
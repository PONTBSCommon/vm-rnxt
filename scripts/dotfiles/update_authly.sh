# fail on any command failing (dont continue)
set -e

AUTHLY_VERSION='1.10.0'

# clone authly origin/master
rm -rf /home/vagrant/authly
git clone git@github.azc.ext.hp.com:Public-Cloud-Core-Services/authly.git /home/vagrant/authly --depth 1

# check out the latest release version
pushd /home/vagrant/authly
git checkout $AUTHLY_VERSION --depth 1 2>/dev/null
popd

# remove the old authly binary, and install the newer one
rm -f /home/vagrant/bin/authly
mkdir /home/vagrant/bin 2>/dev/null || true
mv /home/vagrant/authly/dist/linux_x64/authly /home/vagrant/bin/authly

# clean up, remove the authly repo
rm -rf /home/vagrant/authly
echo "Authly version $AUTHLY_VERSION installed."

printf '\n\n\t=== install necessary tools ===\n\n'
sudo apt update

# hold the grub package. it freezes on install .... :(
# also hold the console-setup package, because of the interactive keyboard locale prompt.
sudo apt-mark hold grub*
sudo apt-mark hold console-setup*

# pre-set keyboard config
setxkbmap us

# update system. (quietly `shh`)
DEBIAN_FRONTEND=noninteractive
TERM=xterm
sudo apt upgrade -yq
sudo apt install awscli maven -yq

# if you dont have aws setup locally run aws configure on first boot to get your creds.
if [ ! -f /home/vagrant/.aws/credentials ]; then
  printf '\n\n\t=== setup connection to wander / s3 artifacts. ===\n\n'
  aws configure
fi

# Add your local ssh key to the vagrant box so you can clone projects.
printf '\n\n\t=== setup ssh authentication ===\n\n'
eval `ssh-agent`
ssh-keygen -R github.azc.ext.hp.com
ssh-keyscan -H github.azc.ext.hp.com >> ~/.ssh/known_hosts
ssh-add ~/.ssh/id_rsa

echo "Updated known_hosts"
cat ~/.ssh/known_hosts

# Pull down the base projects.
printf '\n\n\t=== clone projects ===\n\n'
rm -rf ~/git/wander
rm -rf ~/git/ops
mkdir ~/git/ops
mkdir ~/git/wander

cd ~/git/ops
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git devbox
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd

cd ~/git/wander
git clone git@github.azc.ext.hp.com:Wander/wander-common.git common
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test

# run the wander devbox script to install their tools.
printf '\n\n\t=== install dev tools ===\n\n'
cd ~/git/ops/devbox && sudo -u vagrant ./build.sh DESKTOP
echo 'export JAVA_HOME=/usr/lib/jvm/default-java/' >> ~/.bashrc

# configure kops / kubectl automatically
printf '\n\n\t=== configure kubernetes to point to hpalpine on startup. ===\n\n'
echo ' #### point kops at hpalpine ####
cd ~/git/ops/cicd/
make hpalpine env-app
source env.sh
source kops_env.sh' >> ~/.bashrc

# pull some basic dependencies.
printf '\n\n\t=== install common dependencies ===\n\n'
export JAVA_HOME=/usr/lib/jvm/default-java/
$JAVA_HOME=/usr/lib/jvm/default-java/

cd ~/git/wander/common
mvn clean
cd ~/git/wander/e2e-test
mvn clean
cd ~

source ~/.bashrc

printf '\n\n\t=== Done! === ===\n\n'
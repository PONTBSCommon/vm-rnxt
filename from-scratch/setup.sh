printf '\n\n\t=== install necessary tools ===\n\n'
sudo apt update

# hold the grub package. it freezes on install .... :(
sudo apt-mark hold grub-pc
sudo apt-mark hold grub-common
sudo apt-mark hold grub*

# update system. (quietly `shh`)
DEBIAN_FRONTEND=noninteractive
sudo apt upgrade -yq
sudo apt install awscli maven -y --force-yes

# if you dont have aws setup locally run aws configure on first boot to get your creds.
if [ ! -f /home/vagrant/.aws/credentials ]; then
  printf '\n\n\t=== setup connection to wander / s3 artifacts. ===\n\n'
  aws configure
fi

# Add your local ssh key to the vagrant box so you can clone projects.
printf '\n\n\t=== setup ssh authentication ===\n\n'
eval `ssh-agent`
ssh-keyscan >> ~/.ssh/known_hosts
ssh-add ~/.ssh/id_rsa

# Pull down the base projects. (Make sure you verify the fingerprint when it asks!)
printf '\n\n\t=== clone projects ===\n\n'
cd ~/git
mkdir ops
cd ops
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git devbox
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd

cd ..
mkdir ~/git/wander
cd ~/git/wander
git clone git@github.azc.ext.hp.com:Wander/wander-common.git common
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test

# run the wander devbox script to install their tools.
printf '\n\n\t=== install dev tools ===\n\n'
cd ~/git/ops/devbox && sudo -u vagrant ./build.sh DESKTOP
sudo apt install openjdk-11-jdk -y

# configure kops / kubectl automatically
printf '\n\n\t=== configure kubernetes to point to hpalpine on startup. ===\n\n'
echo ' #### point kops at hpalpine ####
cd ~/git/ops/cicd/
make hpalpine env-app
source env.sh
source kops_env.sh' >> ~/.bashrcyes
source ~/.bashrc

# pull some basic dependencies.
printf '\n\n\t=== install common dependencies ===\n\n'
cd ~/git/wander/common
mvn clean
cd ~/git/wander/e2e-test

printf '\n\n\t=== Done! === ===\n\n'
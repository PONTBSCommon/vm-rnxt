cd ~

printf '\t=== install necessary tools ===\n\n'
# sudo apt update && sudo apt upgrade -y
sudo apt install awscli -y

if [ ! -f /home/vagrant/.aws/credentials ]; then
  printf '\t=== setup connection to wander / s3 artifacts. ===\n\n'
  aws configure
fi

printf '\t=== clone projects ===\n\n'
mkdir git
cd git

ssh-add ~/.ssh/id_rsa

git clone git@github.azc.ext.hp.com:Wander/wander-charts.git
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git
git clone git@github.azc.ext.hp.com:Wander/wander-common.git

printf '\t=== install dev tools ===\n\n'
cd ~/git/wander-devbox
./build.sh DESKTOP

printf '\t=== install dependencies ===\n\n'
cd ~/git/wander-charts
mvn clean
cd ~/git/wander-common
mvn clean

printf '\t=== configure kubernetes to point to hpalpine on startup. ===\n\n'

echo ' #### point kops at hpalpine ####
cd ~/git/wander-cicd/
make hpalpine env-app
source env.sh
source kops_env.sh' >> ~/.bashrc
source ~/.bashrc

printf '\t=== Done! === ===\n\n'
cd ~

printf '\n\n\t=== install necessary tools ===\n\n'
# sudo apt update && sudo apt upgrade -y
sudo apt install awscli -y

if [ ! -f /home/vagrant/.aws/credentials ]; then
  printf '\n\n\t=== setup connection to wander / s3 artifacts. ===\n\n'
  aws configure
fi

printf '\n\n\t=== setup ssh authentication ===\n\n'
eval `ssh-agent`
ssh-add ~/.ssh/id_rsa


printf '\n\n\t=== clone projects ===\n\n'
mkdir git
cd git

git clone git@github.azc.ext.hp.com:Wander/wander-charts.git
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git
git clone git@github.azc.ext.hp.com:Wander/wander-common.git

printf '\n\n\t=== install dev tools ===\n\n'
cd ~/git/wander-devbox
./build.sh DESKTOP

printf '\n\n\t=== install dependencies ===\n\n'
cd ~/git/wander-charts
mvn clean
cd ~/git/wander-common
mvn clean

printf '\n\n\t=== configure kubernetes to point to hpalpine on startup. ===\n\n'

echo ' #### point kops at hpalpine ####
cd ~/git/wander-cicd/
make hpalpine env-app
source env.sh
source kops_env.sh' >> ~/.bashrc
source ~/.bashrc

printf '\n\n\t=== Done! === ===\n\n'
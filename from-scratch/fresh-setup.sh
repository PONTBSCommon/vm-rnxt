#!/bin/bash
cd ~

# install necessary tools
sudo apt update && sudo apt upgrade -y
sudo apt install awscli

# setup connection to wander / s3 artifacts.
mkdir .m2
cp settings.xml .m2/settings.xml
aws configure

# clone projects
mkdir git
cd git

git clone git@github.azc.ext.hp.com:Wander/wander-charts.git
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git
git clone git@github.azc.ext.hp.com:Wander/wander-common.git

#install dev tools
cd ~/git/wander-devbox
./build.sh DESKTOP

# install dependencies
cd ~/git/wander-charts
mvn clean
cd ~/git/wander-common
mvn clean

# configure kubernetes to point to hpalpine on startup.
echo '#### point kops at hpalpine ####
cd ~/git/wander-cicd/
make hpalpine env-app
source env.sh
source kops_env.sh' >> ~/.bashrc
source ~/.bashrc

echo 'Done!'
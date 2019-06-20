source ~/.bashrc
## This script clones the wander projects and downloads their dependencies on first run ##
logf() { echo -e "\n\e[1m\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

logf 'Pull down the base wander projects.'

mkdir ~/git/ops 2>/dev/null

git clone git@github.azc.ext.hp.com:Wander/wander-charts.git ~/git/ops/charts
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git ~/git/ops/cicd
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git ~/git/ops/devbox

mkdir ~/git/wander 2>/dev/null
git clone git@github.azc.ext.hp.com:Wander/wander-common.git ~/git/wander/common
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git ~/git/wander/e2e-test

logf 'install common maven dependencies.'
# boise hp keeps an updated settings.xml in their wander-devbox repository
sudo mv -f ~/git/ops/devbox/base.d/settings.xml /usr/local/apache-maven-${MVN_VER}/conf/settings.xml && \
sudo cp /usr/local/apache-maven-${MVN_VER}/conf/settings.xml ~/.m2/settings.xml && \
sudo rm -rf ~/git/ops/devbox && \
startwd && \
cd ~/git/wander/common && mvn clean install && \
cd ~/git/wander/e2e-test && mvn clean install && \
echo_success && mvn_clean=true

cd ~ && logf '~(˘▾˘~) Installation is complete. Happy coding! (~˘▾˘)~'
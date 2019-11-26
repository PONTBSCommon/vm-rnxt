source ~/.bashrc
## This script clones the wander projects and downloads their dependencies on first run ##
logf() { echo -e "\n\e[1m\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

logf 'Pull down the base wander projects.'
cd ~/git
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git
git clone git@github.azc.ext.hp.com:Wander/wander-common.git
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git

logf 'install common maven dependencies.'
sudo cp ~/git/devbox/base.d/settings.xml ~/.m2/settings.xml && \
cd ~/git/wander/common && mvn clean install && \
cd ~/git/wander/e2e-test && mvn clean install && \
echo_success && mvn_clean=true

cd ~ && logf '~(˘▾˘~) Installation is complete. Happy coding! (~˘▾˘)~'
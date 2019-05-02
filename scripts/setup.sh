## This script clones the wander projects and downloads their dependencies on first run ##
logf() { echo -e "\n\e[1m\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

logf 'Pull down the base wander projects.'
if [ ! -d ~/git/ops ]; then
  mkdir ~/git/ops
fi

cd ~/git/ops
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git devbox
echo -e '\n'

if [ ! -d ~/git/wander ]; then 
  mkdir ~/git/wander
fi

cd ~/git/wander
git clone git@github.azc.ext.hp.com:Wander/wander-common.git common
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test

logf 'install common maven dependencies.'
# boise hp keeps an updated settings.xml in their wander-devbox repository
mv -f ~/git/ops/devbox/base.d/settings.xml /usr/local/apache-maven-${MVN_VER}/conf/settings.xml && \
rm -rf ~/git/ops/devbox && \
cd ~/git/wander/common && mvn dependency:resolve && \
cd ~/git/wander/e2e-test && mvn dependency:resolve && \
echo_success && mvn_clean=true

cd ~ && logf '~(˘▾˘~) Installation is complete. Happy coding! (~˘▾˘)~'
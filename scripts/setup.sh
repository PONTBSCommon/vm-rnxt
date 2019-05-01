## This script clones the wander projects and downloads their dependencies on first run ##
logf() { echo -e "\n\e[1m\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

logf 'Pull down the base wander projects.'
[ ! -d ~/git/ops ] && mkdir ~/git/ops

cd ~/git/ops
[ ! -d ~/git/ops/cicd ] && git clone git@github.azc.ext.hp.com:Wander/wander-charts.git charts
[ ! -d ~/git/ops/charts ] && git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git cicd
[ ! -d ~/git/ops/devbox ] && git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git devbox
echo -e '\n'

[ ! -d ~/git/wander ] && mkdir ~/git/wander
cd ~/git/wander
[ ! -d ~/git/wander/common ] && git clone git@github.azc.ext.hp.com:Wander/wander-common.git common
[ ! -d ~/git/wander/e2e-test ] && git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git e2e-test

logf 'install common maven dependencies.'
# boise hp keeps an updated settings.xml in their wander-devbox repository
mv -f ~/git/ops/devbox/base.d/settings.xml /usr/local/apache-maven-${MVN_VER}/conf/settings.xml && \
rm -r ~/git/ops/devbox && \
cd ~/git/wander/common && mvn dependency:resolve && \
cd ~/git/wander/e2e-test && mvn dependency:resolve && \
echo_success && mvn_clean=true

cd ~ && logf '~(˘▾˘~) Installation is complete. Happy coding! (~˘▾˘)~'
source ~/.bashrc

# functions used only here
echo_success() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39mdone. \e[32m(success)\e[39m"; }
echo_failure() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39merror \e[31m(failure)\e[39m"; }
logf() { echo -e "\n\e[93m[$(date +"%H:%M:%S:%4N")]\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

## This script clones the wander projects and downloads their dependencies on first run ##
logf '[01] pull down the base wander projects.'
rm -rf ~/git/* && \
cd ~/git && \
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-common.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git && \
echo_success || echo_failure

logf '[02] run wander-devbox build.sh setup script'
cd wander-devbox && \
./build.sh && \
echo_success || echo_failure

logf '[03] pull common maven dependencies down from S3'
sudo cp ~/git/devbox/base.d/settings.xml ~/.m2/settings.xml && \
cd ~/git/wander/common && mvn clean install && \
cd ~/git/wander/e2e-test && mvn clean install && \
echo_success || echo_failure

cd ~ && logf '~(˘▾˘~) Installation is complete. Happy coding! (~˘▾˘)~'
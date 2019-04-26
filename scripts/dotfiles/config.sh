export JAVA_HOME=/usr/lib/jvm/default-java/
$PATH = $JAVA_HOME/bin:$PATH

#### point kops at hpalpine ####
cd ~/git/ops/cicd/
make hpalpine env-app
source env.sh
source kops_env.sh

echo -e "vagrant\n" | sudo --stdin dockerd &
# add the java from wander-devbox to path.
if [ -d /usr/lib/jvm/default-java ]; then
  export JAVA_HOME=/usr/lib/jvm/default-java/
  $PATH = $JAVA_HOME/bin:$PATH
fi

# point kops at hpalpine ( kubernetes namespace setup )
if [ -d ~/git/ops/cicd ]; then
  cd ~/git/ops/cicd/
  make hpalpine env-app
  source env.sh
  source kops_env.sh
fi

# start docker
if [ hash dockerd 2>/dev/null ]; then
  echo -e "vagrant\n" | sudo --stdin dockerd &
fi
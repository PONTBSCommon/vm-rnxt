# add openjdk 11 to the environment.
if [ -d /usr/local/openjdk-11.28 ]; then
  echo 'exporting java env'
  export JAVA_HOME="/usr/local/openjdk-11.28"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# add the maven home environment variable
if [ -d /usr/local/apache-maven-3.6.1 ]; then
  echo 'exporting maven env'
  export MAVEN_HOME="/usr/local/apache-maven-3.6.1"
  # no path export. bin is symlinked to /usr/local/bin/mvn
fi

# point kops at hpalpine ( kubernetes namespace setup )
if [ -d ~/git/ops/cicd ]; then
  cd ~/git/ops/cicd/
  make hpalpine env-app
  source env.sh
  source kops_env.sh
  cd ~/git
fi

# start docker
if [ hash dockerd 2>/dev/null ]; then
  echo 'starting docker service'
  echo -e "vagrant\n" | sudo --stdin dockerd &
fi
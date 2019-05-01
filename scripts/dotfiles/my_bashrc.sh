###########################################################
## This file is the vagrant user's custom bashrc profile ##
###########################################################

# run the setup script on first run.
[[ -f /home/vagrant/setup.sh ]] && /home/vagrant/setup.sh | tee ~/.install.log && rm /home/vagrant/setup.sh

source ~/.dotfiles/versions.sh

# add openjdk 11 to the environment.
if [ -d "/usr/local/openjdk-${JDK_VER}" ]; then
  echo 'exporting java env'
  export JAVA_HOME="/usr/local/openjdk-${JDK_VER}"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# add the maven home environment variable
if [ -d "/usr/local/apache-maven-${MVN_VER}" ]; then
  echo 'exporting maven env'
  export MAVEN_HOME="/usr/local/apache-maven-${MVN_VER}"
  # no path export. bin is symlinked to /usr/local/bin/mvn
fi

# aws configuration
if [ ! -f ~/.aws/credentials ]; then
  echo 'please set up your aws credentials.'
  aws configure
else
  echo 'aws creds found.'
fi

# start docker
if [ hash dockerd 2>/dev/null ]; then
  echo 'starting dockerd'
  echo -e "vagrant\n" | sudo --stdin dockerd &
fi

# point kops at hpalpine ( kubernetes namespace setup )
if [ -d ~/git/ops/cicd ]; then
  prev_dir=$(pwd)
  cd ~/git/ops/cicd/
  make hpalpine env-app
  source env.sh
  source kops_env.sh
  cd $prev_dir
fi

# add command completions
if [ hash kops 2>/dev/null ]; then
  source <(kops completion bash)
fi
if [ hash helm 2>/dev/null ]; then
  source <(helm completion bash)
fi
if [ hash kubectl 2>/dev/null ]; then
  source <(kubectl completion bash)
fi
if [ hash docker-compose 2>/dev/null ]; then
  alias dc=docker-compose
fi

# Shortcut functions for wander development.

wander-clone() {
  dir=$(pwd)
  cd ~/git/wander
  folder_name="$(echo $1 | perl -pe 's/wander-//g')"
  echo "git@github.azc.ext.hp.com:Wander/$1.git $folder_name"
  git clone "git@github.azc.ext.hp.com:Wander/$1.git" $folder_name
  cd $dir
}

start-wander-docker() {
  dir=$(pwd)
  cd ~/git/wander/common
  rm ~/.wander_docker.log
  dc up > ~/.wander_docker.log 2>&1 &
  cd $dir
}

stop-wander-docker() {
  dir=$(pwd)
  cd ~/git/wander/common
  dc down
  cd $dir
}

restart-wander-docker() {
  stop-wander-docker
  start-wander-docker
}

# start wander docker containers on login.
start-wander-docker
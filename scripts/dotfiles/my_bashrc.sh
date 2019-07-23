#############################################
### Development Environment Configuration ###
#############################################

source ~/.dotfiles/versions.sh
# add openjdk 11 to the environment.
[ -d "/usr/local/openjdk-${JDK_VER}" ] && export JAVA_HOME="/usr/local/openjdk-${JDK_VER}" && export PATH="$JAVA_HOME/bin:$PATH"

# add the maven home environment variable
[ -d "/usr/local/apache-maven-${MVN_VER}" ] && export MAVEN_HOME="/usr/local/apache-maven-${MVN_VER}"

# add nodejs home to path. 
[ -d "/usr/local/node-v${NODE_VER}-linux-x64/bin" ] && export NODE_HOME="/usr/local/node-v${NODE_VER}-linux-x64/bin" && export PATH="$NODE_HOME:$PATH"

# aws configuration
[ ! -f ~/.aws/credentials ] && aws configure


# point kops at hpalpine ( kubernetes namespace setup )
if [ -d ~/git/ops/cicd ]; then
  prev_dir=$(pwd)
  cd ~/git/ops/cicd/ && make hpalpine env-app >/dev/null && \
  source env.sh >/dev/null && source kops_env.sh
  cd $prev_dir
fi


###############################
### add command completions ###
###############################

[ hash kops 2>/dev/null ] && source <(kops completion bash)
[ hash helm 2>/dev/null ] && source <(helm completion bash)
[ hash kubectl 2>/dev/null ] && source <(kubectl completion bash)


##################################################
### Shortcut functions for wander development. ###
##################################################

wander-clone() { 
  git clone "git@github.azc.ext.hp.com:Wander/$1.git" ~/git/wander/$(echo $1 | perl -pe 's/wander-//g')  
}

start-wander-docker() { 
  sudo rm ~/.wander_docker.log 2>/dev/null
  docker-compose -f ~/git/wander/common/docker-compose.yml up > ~/.wander_docker.log 2>&1 & 
}

stop-wander-docker() {  
  docker-compose -f ~/git/wander/common/docker-compose.yml down
}

restart-wander-docker() { stop-wander-docker && start-wander-docker; }

wander-rdp() {
  cd ~/git/ops/devbox
  git reset --hard && git fetch -p && git pull
  ./desktop.d/
}

##############################
### set shorthand aliases. ###
##############################

alias dc=docker-compose
alias startwd=start-wander-docker
alias stopwd=stop-wander-docker
alias restartwd=restart-wander-docker


#######################################
### Operations To Run On Each Login ###
#######################################

# run the setup script on first run.
[[ -f /home/vagrant/setup.sh ]] && /home/vagrant/setup.sh | tee ~/.install.log && rm /home/vagrant/setup.sh
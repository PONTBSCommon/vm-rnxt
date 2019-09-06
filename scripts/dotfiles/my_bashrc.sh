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

[ -f /usr/local/bin/kops ] && source <(kops completion bash)
[ -f /usr/local/bin/helm ] && source <(helm completion bash)
[ -f /usr/local/bin/kubectl ] && source <(kubectl completion bash)


##################################################
### Shortcut functions for wander development. ###
##################################################

wander-clone() { 
  git clone "git@github.azc.ext.hp.com:Wander/$1.git" ~/git/wander/$(echo $1 | perl -pe 's/wander-//g')  
}

start-wander-docker() { 
  loc=$(pwd)
  cd ~/git/wander/common
  rm -f ./run-docker-log.txt
  ./run-docker &>./run-docker-log.txt &
  cd $loc
}

stop-wander-docker() {  
  docker-compose -f ~/git/wander/common/docker-compose.yml down
}

restart-wander-docker() { stop-wander-docker && start-wander-docker; }


update-wander-master() {
  loc=$(pwd)
  cd ~/git/wander
  for subdir in `ls`
  do
    cd $subdir
    git fetch -p
    git pull
    cd ..
  done
  cd $loc
}

update-ops-master() {
  loc=$(pwd)
  cd ~/git/ops
  for subdir in `ls`
  do
    cd $subdir
    git fetch -p
    git pull
    cd ..
  done
  cd $loc
}
function update-all-master() {
  update-wander-master
  update-ops-master
}
##############################
### set shorthand aliases. ###
##############################

alias dc=docker-compose
alias startwd=start-wander-docker
alias stopwd=stop-wander-docker
alias restartwd=restart-wander-docker
alias pullwander=update-wander-master
alias pullops=update-ops-master
alias pullall=update-all-master

#######################################
### Operations To Run On Each Login ###
#######################################

# run the setup script on first run.
[[ -f /home/vagrant/setup.sh ]] && /home/vagrant/setup.sh | tee ~/.install.log && rm /home/vagrant/setup.sh
#############################################
### Development Environment Configuration ###
#############################################

# aws configuration
[ ! -f ~/.aws/credentials ] && aws configure


###############################
### add command completions ###
###############################
[ -f /usr/local/bin/kops ] && source <(kops completion bash)
[ -f /usr/local/bin/helm ] && source <(helm completion bash)
[ -f /usr/local/bin/kubectl ] && source <(kubectl completion bash)


##################################################
### Shortcut functions for wander development. ###
##################################################
start-wander-docker() { 
  loc=$(pwd)
  cd ~/git/wander-common
  rm -f ./run-docker-log.txt
  ./run-docker &>./run-docker-log.txt &
  cd $loc
}

stop-wander-docker() {  
  docker-compose -f ~/git/wander-common/docker-compose.yml down
}

restart-wander-docker() { stop-wander-docker && start-wander-docker; }

update-wander-master() {
  loc=$(pwd)
  cd ~/git
  for subdir in `ls`
  do
    cd $subdir
    git fetch -p
    git pull
    cd ..
  done
  cd $loc
}

###############################
# Kubernetes cluster switches #
###############################

# Shared function for using authly to authenticate against a kubernetes cluster
#   $1 is the ARN of the ADFS role to authenticate with
#   $2 is the name of the kubernetes cluster to authenticate against
function aws_auth {
    echo "Authenticating as $1"
    authly --rolearn $1
    export AWS_PROFILE=default
    pushd ~/git/wander-cicd
    make $2 env-app
    source env.sh
    source kops_env.sh
    popd  
}

# Computes the ARN of an ADFS role for the alpine-prod environment
#   $1 is the name of the ADFS role to assume. If not specified, the DEVELOPER role will be used
function get_alpine_prod_arn {
    local arn="arn:aws:iam::175611431549:role/"
    if [[ -z "$1" ]]
    then
        arn+="DEVELOPER"
    else
        arn+="$1"
    fi
    echo "$arn"
}

# Switches to the eu-central-1 (PROD EMEA) kubernetes cluster
#   $1 is the name of the ADFS role to assume. If not specified, the DEVELOPER role will be used
function eu_central_1_aws {
    local arn=$(get_alpine_prod_arn $1)
    aws_auth $arn eu-central-1
}
function aws_eu_central_1 {
    eu_central_1_aws $1
}

# Switches to the us-east-1 (PROD NA) kubernetes cluster
#   $1 is the name of the ADFS role to assume. If not specified, the DEVELOPER role will be used
function us_east_1_aws {
    local arn=$(get_alpine_prod_arn $1)
    aws_auth $arn us-east-1
}
function aws_us_east_1 {
    us_east_1_aws $1
}

# Switches to the beta kubernetes cluster
#   $1 is the name of the ADFS role to assume. If not specified, the DEVELOPER role will be used
function beta_aws {
    local arn=$(get_alpine_prod_arn $1)
    aws_auth $arn beta
}
function aws_beta {
    beta_aws $1
}

function dev_aws {
    aws_auth arn:aws:iam::037487371311:role/DEVELOPER hpalpine
}
function aws_dev {
    dev_aws
}

function goblin_aws {
    aws_auth arn:aws:iam::037487371311:role/ADMIN goblin
}
function aws_goblin {
    goblin_aws
}

function ogre_aws {
    aws_auth arn:aws:iam::037487371311:role/ADMIN ogre
}
function aws_ogre {
    ogre_aws
}

function babel_aws {
    aws_auth arn:aws:iam::037487371311:role/ADMIN babel
}
function aws_babel {
    babel_aws
}

function hedevil_aws {
    aws_auth arn:aws:iam::037487371311:role/ADMIN hedevil
}
function aws_hedevil {
    hedevil_aws
}

function shedevil_aws {
    aws_auth arn:aws:iam::037487371311:role/ADMIN shedevil
}
function aws_shedevil {
    shedevil_aws
}

function china_aws {
  export AWS_PROFILE=china
  pushd ~/git/wander-cicd
  make cn-northwest-1 env-app
  source env.sh
  source kops_env.sh
  popd
}
function aws_china {
  china_aws
}

# Opens a mysql terminal for executing requests against the database
#   $1 is the name of the namespace whose database you want to connect to. Run kubectl get namespaces to see a list of available namespaces. In prod, the namespace is usually called "wander"
function k8_mysql {
  STACK_NAME=$1

  mysql_user=$(kubectl get secret -n ${STACK_NAME} service-dependencies -o jsonpath="{.data.mysql_username}" | base64 --decode)
  mysql_password=$(kubectl get secret -n ${STACK_NAME} service-dependencies -o jsonpath="{.data.mysql_password}" | base64 --decode)
  endpoint=$(kubectl get configmaps -n ${STACK_NAME} service-dependencies -o jsonpath="{.data.mysql_endpoint}")
  bastion=$(kubectl get pods -n ${STACK_NAME} | grep bastion | awk '{print $1;}')

  kubectl exec -it $bastion -n ${STACK_NAME} -- bash -c "mysql --binary-as-hex -h $endpoint -u '$mysql_user' -p$mysql_password"
}

k8_redis() {
  endpoint=$(kubectl get configmaps -n $1 service-dependencies -o jsonpath="{.data.redis_endpoint}")
  password=$(kubectl get secret -n $1 service-dependencies -o jsonpath="{.data.redis_password}" | base64 --decode)
  bastion=$(kubectl get pods -n $1 | grep bastion | awk '{print $1;}')
  kubectl exec -it $bastion -n $1 -- bash -c "/usr/local/bin/redis-cli-ssl $endpoint $password"
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
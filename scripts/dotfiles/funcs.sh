logf() {
  echo -e "\n\e[1m\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"
}

tablef() {
  if [ $2 == true ]; then
    $status = "\e[32msuccess\e[39m"
  else
    $status = "\e[31mfailure\e[39m"
  fi
  printf "%15s:\t%s", $1, $status
}


echo_success() {
  echo -e "done. \e[32m(success)\e[39m"
}

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
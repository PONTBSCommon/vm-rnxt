logf() {
  echo -e "\n\e[1m\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"
}

wander-clone() {
  dir=$(pwd)
  cd ~/git/wander
  folder_name="$(echo $1 | perl -pe 's/wander-//g')"
  git clone "git@github.azc.ext.hp.com:Wander/$1.git $folder_name"
  cd $dir
}
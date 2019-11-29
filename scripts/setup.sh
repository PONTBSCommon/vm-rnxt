# this script runs as vagrant the first time that user shells into the box with `vagrant ssh`
# its goal is to run the wander-devbox build.sh script that installs all of the basic tooling, clone a few of the common 
# repositories, and run the maven builds to ensure that everything is working as desired

source ~/.bashrc

# functions used only here
echo_success() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39mdone. \e[32m(success)\e[39m"; }
echo_failure() { echo -e "\e[93m[$(date +"%H:%M:%S:%4N")] \e[39merror \e[31m(failure)\e[39m"; }
logf() { echo -e "\n\e[93m[$(date +"%H:%M:%S:%4N")]\e[95m === \e[1;39m$1\e[0;95m === \e[39m\e[21m\n"; }

## clones the wander projects and downloads their dependencies on first run
logf '[14/19] pull down the base wander projects.'
rm -rf ~/git/* && \
cd ~/git && \
git clone git@github.azc.ext.hp.com:Wander/wander-charts.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-cicd.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-devbox.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-common.git && \
git clone git@github.azc.ext.hp.com:Wander/wander-e2e-test.git && \
echo_success || echo_failure

# runs the wander-devbox setup script, installing the base set of utilities
logf '[15/19] run wander-devbox build.sh setup script'
cd wander-devbox && \
./build.sh && \
echo_success || echo_failure

# fixes python path for docker and docker-compose - see https://github.com/docker/docker-py/issues/1502#issuecomment-418346541
# this may need to be moved into wander-devbox/base.d/S21docker.sh if it affects linux/macos users that aren't in vagrant vms
logf '[16/19] fix docker and docker-compose'
sudo cp -r /usr/local/lib/python2.7/dist-packages/backports/ssl_match_hostname /usr/lib/python2.7/dist-packages/backports/ && \
sudo cp -r /usr/local/lib/python2.7/dist-packages/backports/shutil_get_terminal_size /usr/lib/python2.7/dist-packages/backports/ && \
echo_success || echo_failure

# authenticates the user so that they can pull dependencies down from S3
# requires user interaction
logf '[17/19] authenticate with ADFS'
authly && \
echo_success || echo_failure

# brings the docker containers from wander-common online. These are required to run tests for most wander microservices
# the docker_login code was stolen from wander-common/run-docker.sh. It would be best to run that script directly, but it doesn't run the containers in daemon mode,
# and for the purposes of this script, we need to background the containers so that we can finish the setup
logf '[18/19] start wander-common docker containers'
cd ~/git/wander-common && \
docker_login=$(aws ecr get-login --region us-west-2 --no-include-email --registry-ids 037487371311) && \
eval $docker_login && \
docker-compose up -d && \
echo_success || echo_failure

# sets up maven and pulls a base set of dependencies down from S3 so that projects build faster
# does not run E2E tests because they are slow and occasionally flake out!
logf '[19/19] download maven dependencies down from S3'
sudo cp ~/git/wander-devbox/base.d/settings.xml ~/.m2/settings.xml && \
cd ~/git/wander-common && mvn clean test && \
cd ~/git/wander-e2e-test && mvn clean compile && \
echo_success || echo_failure

cd ~ && logf '~(˘▾˘~) Installation is complete. Happy coding! (~˘▾˘)~'
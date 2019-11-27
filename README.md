# Instructions #
- run through [these setup steps](https://github.azc.ext.hp.com/Wander/wander-wiki/wiki/YKF-Transition-Notes:-Development-Environment-Setup)
- run the command `vagrant up`
  - vagrant will install the necessary plugins and download ubuntu
  - you may see `==> default: Disk cannot be decreased in size. 51200 MB requested but disk is already 65536 MB.` This is fine. 
- once complete, run `vagrant ssh`
- on first boot tools will install. 
- follow the on screen prompts.

# Prerequisites #
- ssh / ssh keys for github ***(required)*** - if you have git bash / ssh set up, you're good.
- awscli ***(optional / recommended)*** - not necessary, but you'll have to set up your credentials manually.
  - install here: https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html
- maven .m2/repository - the repository folder is shared automatically to save download time.

# Default Directory Layout #
- some default wander repositories are cloned into the `~/git` folder in the vm
- your host machine's `~/.m2/repository` folder will be shared to `/home/vagrant/.m2/repository` in the vm
- your host machine's `~/.aws` folder will be shared to `/home/vagrant/.aws` in the vm

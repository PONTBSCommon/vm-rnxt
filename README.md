# Instructions #
- take a look at **Local Setup** first.
- run the command `vagrant up`
  - vagrant will install the necessary plugins and download ubuntu
  - you may see `==> default: Disk cannot be decreased in size. 51200 MB requested but disk is already 65536 MB.` This is fine. 
- once complete, run `vagrant ssh`
- on first boot tools will install. 
- follow the on screen prompts.

# Local Setup #
**this setup is simplest when your windows laptop is already set up with a few tools.**
- ssh / ssh keys for github ***(required)*** - if you have git bash / ssh set up, you're good.
- awscli ***(optional / recommended)*** - not necessary, but you'll have to set up your credentials manually.
  - install here: https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html
- maven .m2/repository - the repository folder is shared automatically to save download time.

# Default Directory Layout #
- The git folder is stored under `~/git` (Locally under `./rnxt/git/`)
- `wander-charts`, and `wander-cicd` are stored under `~/git/ops/` as `charts`, and `cicd`.
- `wander-common`, and `wander-e2e-test` are stored under `~/git/wander/` as `common`, and `e2e-test`.
- the recommendation is to clone new projects under `~/git/wander/` with the `wander-` prefix removed.
  - folder name can be specified at clone time. (eg: `git clone git@github.azc.ext.hp.com:Wander/wander-printer-status.git printer-status`)
  - `wander-clone [project-name]` is a built in function in `~/.dotfiles/funcs.sh` that clones to `~/git/wander` and removes the prefix from the folder. 
  - (example: `wander-clone wander-printer-status`)

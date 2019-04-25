# Instructions #
- `cd` into the `from-scratch/` folder.
- run the command `vagrant up`
  - vagrant will install the necessary plugins and download ubuntu
  - you may see `==> default: Disk cannot be decreased in size. 51200 MB requested but disk is already 65536 MB.` This is fine. 
- once complete, run `vagrant ssh`
- on first boot tools will install. 
- follow the on screen prompts.

# Configuration #
- if you have aws configured locally, it will be copied in.
- if you have a git ssh key configured locally it will be copied in.
- the maven settings are included here and will be copied in.

# Default Directory Layout #
- The git folder is stored under `~/git`
- `wander-charts`, `wander-cicd`, and `wander-devbox` are stored under `~/git/ops/` as `charts`, `cicd`, and `devbox`.
- `wander-common`, and `wander-e2e-test` are stored under `~/git/wander/` as `common`, and `e2e-test`.
- the recommendation is to clone new projects under `~/git/wander/` with the `wander-` prefix removed.
  - folder name can be specified at clone time. (eg: `git clone git@github.azc.ext.hp.com:Wander/wander-printer-status.git printer-status`)
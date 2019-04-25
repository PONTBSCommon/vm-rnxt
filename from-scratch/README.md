# Instructions #

- run the script `vagrant-plugins.ps1` (or copy and paste the command from the script file)
- `cd` into the `from-scratch/` folder.
- run the command `vagrant up`
- once complete, run `vagrant ssh`
- on first boot tools will install. 
- follow the on screen prompts.

# Configuration #
- if you have aws configured locally, it will be copied in.
- if you have a git ssh key configured locally it will be copied in.
- the maven settings are included here and will be copied in.

# Update Notes #
- *For keyboard config prompt*: Accept US layout defaults 
  - (press enter twice)
- *For GRUB update*: dont update GRUB.
  - (press tab, enter, tab, enter)
- *For `(Y/I/N/O/D/Z) [default=N] ?` prompts*: Accept defaults
  - (press enter)


# Default Directory Layout #
- The git folder is stored under `~/git`
- `wander-charts`, `wander-cicd`, and `wander-devbox` are stored under `~/git/ops/` as `charts`, `cicd`, and `devbox`.
- `wander-common`, and `wander-e2e-test` are stored under `~/git/wander/` as `common`, and `e2e-test`.
- the recommendation is to clone new projects under `~/git/wander/` with the `wander-` prefix removed.
  - folder name can be specified at clone time. (eg: `git clone git@github.azc.ext.hp.com:Wander/wander-printer-status.git printer-status`)
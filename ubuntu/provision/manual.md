# Manual Updates from the Arch Linux Provision

- update `install_pacman_package` to `install_system_package` (TODO: update this)
- update `install_system_package` to use apt-get
- add: `install_system_package build-essential make`
- update: silver searcher install name to: `silversearcher-ag`
- update `WifiConnect` alias to use only `nmtui` in `general-extras` provision
- add `n` alias to point to `vim` instead of neovim (till nvim supported in Ubuntu provision)
- update `python-pip pip3` by `python3-pip pip3` in vim-extras

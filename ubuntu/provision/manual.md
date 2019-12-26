# Manual Updates from the Arch Linux Provision

- update `install_pacman_package` to `install_system_package` (TODO: update this)
- update `install_system_package` implementation to use apt-get
- add: `install_system_package build-essential make`
- update: silver searcher install name to: `silversearcher-ag`
- update `WifiConnect` alias to use only `nmtui` in `general-extras` provision
- update `python-pip pip3` by `python3-pip pip3` in vim-extras
- in order to use autocomplete, use the latest version of neovim
    - download the release from: https://github.com/neovim/neovim/releases/
- install `cryptsetup` for same encryption support as Arch

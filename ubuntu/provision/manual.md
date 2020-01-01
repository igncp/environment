# Manual Updates from the Arch Linux Provision

- update `install_pacman_package` to `install_system_package` (TODO: update this)
- update `install_system_package` implementation to use apt-get
- remove all `pacman` occurrences
- add: `install_system_package build-essential make`
- update: silver searcher install name to: `silversearcher-ag`
- update `WifiConnect` alias to use only `nmtui` in `general-extras.sh` provision
- update `python-pip pip3` by `python3-pip pip3` in `vim-extras.sh` provision
- in order to use autocomplete, use the latest version of neovim
    - download the release from: https://github.com/neovim/neovim/releases/
- install `cryptsetup` for same encryption support as Arch
- if there is a black screen after boot:
    - On booting, press `Esc` to enter the GRUB screen
    - Press `e` on the `Ubuntu` line to enter the Edit Mode
    - Change `ro quiet splash` by `nomodeset quiet splash`
    - After login, run: `sudo apt-get install -y lightdm; sudo dkpg-reconfigure lightdm; sudo reboot now`
- update keyboard layout if necessary:
    - Update `/etc/default/keyboard`

# Mac Provision

## Always

- Replace `[^~]\/project` into `~/project`
- Replace `/home/igncp` and `/home/$USER` by `$HOME`

## Config

- Update keyboard shortcuts for Mission Control
- Update Preferences > Accessibility > Use less motion - removes the animation when switching virtual desktops

## Steps

- Place the `project` directory in `~/project`
- Manually install `nvim`: https://github.com/neovim/neovim/releases/tag/v0.4.3
- Install `brew` command
- If there are issues with `brew`, run `xcode-select --install`
- `brew install gnu-sed --with-default-names`
- Add `./mac-beginning.sh` into `~/project/provision/provision.sh`
- Update git config
- Add Arch's `general.sh`
    - Only keep alias and `fzf` config
- Add Arch's `vim-base.sh`
- Add Arch's `js.sh`
- Add `./mac-final.sh`
- Add Arch's `custom.sh`

#!/usr/bin/env bash

set -e

. src/zsh/unalias.sh

install_omzsh_plugin() {
  local REPONAME=$1
  local NAME="$(echo $REPONAME | cut -d'/' -f2)"
  local DIR="$HOME/.oh-my-zsh/custom/plugins/$NAME"

  if [ ! -d "$DIR" ]; then
    echo "Installing oh-my-zsh plugin: $NAME"
    git clone --depth=1 https://github.com/$REPONAME.git "$DIR"
  fi

  echo "source $DIR/$NAME.plugin.zsh" >>~/.zshrc
}

provision_setup_zsh() {
  if [ ! -d ~/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh) --unattended --keep-zshrc"
    mkdir -p ~/.cache/zsh
  fi

  # These have to be before the main zsh block
  install_omzsh_plugin "zsh-users/zsh-completions"
  install_omzsh_plugin "hlissner/zsh-autopair"
  install_omzsh_plugin "zsh-users/zsh-syntax-highlighting"
  install_omzsh_plugin "MichaelAquilina/zsh-you-should-use"

  # If running through NixOS for example, SHELL will have a different value and it will be
  # already set

  cat ~/development/environment/src/config-files/zsh.sh >>~/.zshrc

  echo "SHELL=$(which zsh)" >>~/.zshrc

  if [ ! -f ~/.bun/_bun ] && type "bun" >/dev/null 2>&1; then
    mkdir -p ~/.bun
    bun completions >~/.bun/_bun
  fi

  cat >>~/.shellrc <<"EOF"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

ShellChangeToZsh() {
  SHELL_PATH=$(which zsh)
  if [ -n "$(which zsh | grep nix)" ]; then
    if [ -z "$(cat /etc/shells | grep nix)" ]; then
      cat /etc/shells > /tmp/shells
      which zsh >> /tmp/shells
      sudo mv /tmp/shells /etc/shells
      sudo chown root:root /etc/shells
    fi
  fi
  chsh -s $(which zsh); exit
}
EOF

  if [ "$IS_LINUX" == "1" ]; then
    echo 'eval "$(dircolors /home/$USER/.dircolors)"' >>~/.zshrc

    if [ ! -f ~/.zsh/_git ]; then
      mkdir -p ~/.zsh
      curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
    fi
  fi

  echo 'fpath=(~/.zsh $fpath)' >>~/.zshrc

  provision_setup_zsh_unalias

  # Having this at the end to allow setting some aliases that were removed in
  # `provision_setup_zsh_unalias`
  cat >>~/.zshrc <<"EOF"
source $HOME/.shellrc
source $HOME/.shell_sources
EOF
}

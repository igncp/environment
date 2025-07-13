#!/usr/bin/env bash

set -euo pipefail

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

  IS_ZSH="$(echo $SHELL | grep zsh || true)"

  # 例如 `printf en_US.UTF-8 > ~/development/environment/project/.config/cli_locale`
  if [ -f "$PROVISION_CONFIG"/cli_locale ]; then
    CLI_LOCALE=$(cat "$PROVISION_CONFIG"/cli_locale)
    sed -i "s|export LANG=.*|export LANG=$CLI_LOCALE|" ~/.zshrc
    sed -i "s|export LC_ALL=.*|export LC_ALL=$CLI_LOCALE|" ~/.zshrc
  fi

  if [ ! -f ~/.oh-my-zsh/completions/_bun ] && [ -n "$IS_ZSH" ] && type "bun" >/dev/null 2>&1; then
    mkdir -p ~/.oh-my-zsh/completions/
    bun completions ~/.oh-my-zsh/completions/
  fi

  if ! type "nix" >/dev/null 2>&1; then
    echo 'source <(fzf --zsh)' >>~/.zshrc
  fi

  cat >>~/.shellrc <<"EOF"
ShellChangeToZsh() {
  SHELL_PATH=$(which zsh)
  if [ -n "$(which zsh | grep nix)" ]; then
    if [ -z "$(cat /etc/shells | grep nix)" ]; then
      sudo cat /etc/shells > /tmp/shells
      which zsh >> /tmp/shells
      sudo mv /tmp/shells /etc/shells
      sudo chown root:root /etc/shells
    fi
  fi
  chsh -s $(which zsh); exit
}
EOF

  if [ "$IS_LINUX" == "1" ]; then
    if type "dircolors" >/dev/null 2>&1; then
      echo 'eval "$(dircolors /home/$USER/.dircolors)"' >>~/.zshrc
    fi
    if [ ! -f ~/.zsh/_git ]; then
      mkdir -p ~/.zsh
      local url="https://raw.githubusercontent.com/felipec/git-completion"
      local version="1.3.7"
      cd ~/.zsh
      # All of these three are used by zsh, even if it seems that only _git is
      curl -s -o _git "${url}/v${version}/git-completion.zsh" &&
        curl -s -o git-completion.bash "${url}/v${version}/git-completion.bash" &&
        curl -s -o git-prompt.sh "${url}/v${version}/git-prompt.sh"
      unset url version
      cd ~/development/environment
    fi
  fi

  echo 'fpath=('"$HOME"'/.zsh $fpath)' >>~/.zshrc

  provision_setup_zsh_unalias

  # Having this at the end to allow setting some aliases that were removed in
  # `provision_setup_zsh_unalias`
  cat >>~/.zshrc <<"EOF"
source $HOME/.shellrc
source $HOME/.shell_sources

# 此變數由 Nix 設定以應用語法突出顯示。此行刪除突出顯示。
export LESSOPEN=""
EOF
}

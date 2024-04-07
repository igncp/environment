#!/usr/bin/env bash

set -e

clone_dev_github_repo() {
  local DIR_PATH="$HOME/development/$1"

  if [ ! -d "$DIR_PATH" ]; then
    git clone "git@github.com:igncp/$1.git" "$DIR_PATH"
  fi
}

provision_setup_custom() {
  sed -i 's|syntax off||' ~/.vimrc

  cat >>~/.shellrc <<"EOF"
if [ -z "$TMUX" ]; then
  echo 'check if running in VM and remove condition if yes, either way remove this message'
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo 'ssh, not running tmux'
  elif [ "$(tmux list-clients 2> /dev/null | wc -l | tr '\n' '_')" != "0_" ]; then
    echo 'there is already a tmux client, not attaching to session'
  elif [ -n "$(pgrep tmux)" ]; then
    tmux attach
  elif [ -f "$HOME"/development/environment/src/scripts/bootstrap/Bootstrap_common.sh ]; then
    bash "$HOME"/development/environment/src/scripts/bootstrap/Bootstrap_common.sh
  elif [ ! -f $HOME/development/environment/project/.config/no-auto-tmux ]; then
    tmux
  fi
fi
EOF

  # git config --global user.name 'Foo Bar'
  # git config --global user.email foo@bar.com
  # git config --global gpg.format ssh
  # git config --global commit.gpgsign true
  # git config --global user.signingkey '...' # Public SSH key
  # git config --global core.editor nvim
  ## If using 1Password directly Linux, this is needed
  # git config --global gpg.ssh.program /opt/1Password/op-ssh-sign
  # mkdir -p "$HOME"/.config/git/git
  # git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
  # # This file is used for `git log --show-signature`, have to add the public key instead of `...`
  # echo "icarbajop@gmail.com ..." > "$HOME"/.config/git/allowed_signers

  if [ ! -f "$HOME"/.check-files/git-info ]; then
    echo '[~/.check-files/git-info]: configure git user and email info'
  fi

  clone_dev_github_repo environment

  jq -S "." ~/.vim/coc-settings.json | sponge ~/.vim/coc-settings.json

  cat >>~/.zshrc <<"EOF"
zle -N custom_dir
custom_dir () {
  FILE=$(fd . ~/development/environment --type f | fzf)
  LBUFFER="n $FILE"
  zle accept-line # enter
}
bindkey "\C-q\C-i" custom_dir
EOF
}

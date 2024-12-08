#!/usr/bin/env bash

set -e

clone_dev_github_repo() {
  local DIR_PATH="$HOME/development/$1"

  if [ ! -d "$DIR_PATH" ]; then
    git clone "git@github.com:igncp/$1.git" "$DIR_PATH"
  fi
}

provision_setup_end() {
  sed -i 's|syntax off||' ~/.vimrc

  if [ -f "$PROVISION_CONFIG"/job ]; then
    echo 'BOOTSTRAP_FILE=~/development/environment/src/scripts/bootstrap/Bootstrap_job.sh' >>~/.shellrc
  else
    echo 'BOOTSTRAP_FILE=~/development/environment/src/scripts/bootstrap/Bootstrap_common.sh' >>~/.shellrc
  fi

  cat >>~/.shellrc <<"EOF"
if [ -z "$TMUX" ]; then
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo 'ssh，未運行 tmux'
  elif [ "$(tmux list-clients 2> /dev/null | wc -l | tr '\n' '_')" != "0_" ]; then
    echo '已經有一個 tmux 用戶端，未附加到會話'
  elif [ -n "$(pgrep tmux)" ]; then
    tmux attach
  elif [ -f "$BOOTSTRAP_FILE" ]; then
    bash "$BOOTSTRAP_FILE"
  elif [ ! -f $HOME/development/environment/project/.config/no-auto-tmux ]; then
    tmux
  fi
fi
EOF

  git config --global user.name 'Ignacio'
  git config --global user.email icarbajop@gmail.com

  if [ -f "$PROVISION_CONFIG"/git-ssh ]; then
    git config --global gpg.format ssh
    git config --global commit.gpgsign true
    git config --global user.signingkey "$(cat $PROVISION_CONFIG/git-ssh)" # 公開嘅 SSH 密鑰
    ## 如果Linux直接使用1Password，則需要這個
    # git config --global gpg.ssh.program /opt/1Password/op-ssh-sign
  fi

  git config --global core.editor nvim
  # mkdir -p "$HOME"/.config/git/git
  # git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
  # # 該檔案用於“git log --show-signature”，必須添加公鑰而不是“...”
  # echo "icarbajop@gmail.com ..." > "$HOME"/.config/git/allowed_signers

  if [ ! -f "$HOME"/.check-files/git-info ]; then
    echo '[~/.check-files/git-info]: configure git user and email info'
  fi

  clone_dev_github_repo environment

  if [ ! -f ~/development/environment/src/scripts/bootstrap/Bootstrap_common.sh ]; then
    cp ~/development/environment/src/scripts/bootstrap/_Bootstrap_template.sh \
      ~/development/environment/src/scripts/bootstrap/Bootstrap_common.sh
  fi

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

  if [ -f src/custom.sh ]; then
    . src/custom.sh
    provision_setup_custom
  fi
}

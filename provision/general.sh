#!/usr/bin/env bash

# general START

if [ -d /project/scripts ]; then chmod -R +x /project/scripts; fi

mkdir -p ~/logs

if ! type jq > /dev/null 2>&1 ; then
  echo "installing basic packages"
  sudo apt-get update
  sudo apt-get install -y curl git unzip git-extras \
    build-essential python-software-properties tree entr jq

  git config --global user.email "foo@bar.com" && \
    git config --global user.name "Foo Bar" && \
    git config --global core.editor "vim"
fi

# shellcheck (without using stack, it takes a while to install)
  # if [ ! -f ~/.cabal/bin/shellcheck ]; then
  #   echo "installing shellcheck without using stack"
  #   sudo apt-get install -y cabal-install
  #   cabal update
  #   cabal install shellcheck
  # fi

if [ ! -d ~/src ]; then
  if [ -d /project/src ]; then cp -r /project/src ~; fi
fi

cat > ~/.bashrc <<"EOF"
# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

stty -ixon # prevent the terminal from hanging on ctrl+s

export HISTCONTROL=ignoreboth:erasedups

source_if_exists() {
  FILE_PATH=$1
  if [ -f $FILE_PATH ]; then source $FILE_PATH; fi
}

source_if_exists ~/.bash_aliases

if [[ -z $TMUX ]]; then TMUX_PREFIX="·"; else TMUX_PREFIX="{$(tmux display-message -p '#I')} £"; fi
get_jobs_prefix() {
  JOBS=$(jobs | wc -l)
  if [ "$JOBS" -eq "0" ]; then echo ""; else echo "[$JOBS] "; fi
}
PS1='${debian_chroot:+($debian_chroot)}\n\u@\h: \W$(__git_ps1) $(get_jobs_prefix)$TMUX_PREFIX '

export PATH=$PATH:/project/scripts
export PATH=$PATH:/project/provision
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cabal/bin

if [ -d ~/src ]; then cd ~/src; fi
EOF

cat >> ~/.bashrc <<"EOF"
alias ll="ls -lah"
alias rm="rm -rf"
alias mkdir="mkdir -p"
alias cp="cp -r"

alias Tmux="tmux; exit"
alias EditProvision="vim /project/provision/provision.sh && provision.sh"
alias Exit="killall tmux > /dev/null 2>&1 || exit"
Find() { find $@ ! -path "*node_modules*" ! -path "*.git*"; }

alias GitStatus='git status -u'
GitAdd() { git add -A $@; GitStatus; }
alias GitAddAll='GitAdd .'
alias GitCommit='git commit -m'

UpdateSrc() {
  rm -rf /project/src
  rsync -av \
    --exclude='*node_modules*' \
    ~/src /project
}
EOF

cat > ~/.tmux.conf <<"EOF"
set -g status off
set-window-option -g xterm-keys on

bind-key S-Left swap-window -t -1
bind-key S-Right swap-window -t +1
EOF

# general END

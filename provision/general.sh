#!/usr/bin/env bash

if [ -d /project/scripts ]; then chmod -R +x /project/scripts; fi

mkdir -p ~/logs

if ! type jq > /dev/null 2>&1 ; then
  echo "installing basic packages"
  sudo apt-get update
  sudo apt-get install -y curl git unzip ack-grep git-extras \
    build-essential python-software-properties tree jq

  git config --global user.email "foo@bar.com" && git config --global user.name "Foo Bar"
fi

# shellcheck (without using stack, it takes a while to install)
  if [ ! -f ~/.cabal/bin/shellcheck ]; then
    echo "installing shellcheck without using stack"
    sudo apt-get install -y cabal-install
    cabal update
    cabal install shellcheck
  fi

if [ ! -d ~/src ]; then cp -r /project/src ~; fi

cat > ~/.bashrc <<"EOF"
# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

stty -ixon # prevent the terminal from hanging on ctrl+s

source_if_exists() {
  FILE_PATH=$1
  if [ -f $FILE_PATH ]; then source $FILE_PATH; fi
}

source_if_exists ~/.bash_aliases

if [[ -z $TMUX ]]; then TMUX_PREFIX="·"; else TMUX_PREFIX="£"; fi
PS1='${debian_chroot:+($debian_chroot)}\n\u@\h: \W$(__git_ps1) $TMUX_PREFIX '

alias ll="ls -lah"
alias rm="rm -rf"
alias mkdir="mkdir -p"
alias cp="cp -r"
alias tmux="tmux; exit"

Update_src() {
  rm -rf /project/src
  rsync -av \
    --exclude='*node_modules*' \
    ~/src /project
}

export PATH=$PATH:/project/scripts
export PATH=$PATH:/project/provision
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cabal/bin

# nodenv
  export PATH=$PATH:/home/$USER/.nodenv/bin
  export PATH=$PATH:/home/$USER/.nodenv/versions/6.3.0/bin/
  eval "$(nodenv init -)"
  source <(npm completion)

# haskell
  alias runghc="stack exec runghc --silent -- -w -ihs"
  alias vim="stack exec vim"

# wordpress
  source_if_exists ~/wp-completion.bash

# drush
  source_if_exists ~/.drush/drush.bashrc
  source_if_exists ~/.drush/drush.complete.sh
  source_if_exists ~/.drush/drush.prompt.sh

# java
  export GRADLE_HOME=/usr/local/lib/gradle
  export PATH=$PATH:"$GRADLE_HOME"/bin
  source_if_exists ~/gradle-tab-completion.bash

if [ -d ~/src ]; then cd ~/src; fi
EOF

cat > ~/.tmux.conf <<"EOF"
set -g status off
set-window-option -g xterm-keys on

bind-key S-Left swap-window -t -1
bind-key S-Right swap-window -t +1
EOF

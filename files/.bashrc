# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

stty -ixon # prevent the terminal from hanging on ctrl+s

function source_if_exists() {
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

export PATH=$PATH:/project/scripts
export PATH=$PATH:/project/provision
export PATH=$PATH:~/.local/bin

# nodenv
  export PATH=$PATH:/home/$USER/.nodenv/bin
  export PATH=$PATH:/home/$USER/.nodenv/versions/6.3.0/bin/
  eval "$(nodenv init -)"
  source <(npm completion)

# haskell
  alias runghc="stack exec runghc --silent -- -w -ihs"
  alias vim="stack exec vim"

# wordpress
  source ~/wp-completion.bash

# drush
  source_if_exists ~/.drush/drush.bashrc
  source_if_exists ~/.drush/drush.complete.sh
  source_if_exists ~/.drush/drush.prompt.sh

if [ -d ~/src ]; then cd ~/src; fi

# java
  export GRADLE_HOME=/usr/local/lib/gradle
  export PATH=$PATH:"$GRADLE_HOME"/bin
  source_if_exists ~/gradle-tab-completion.bash
# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

stty -ixon # prevent the terminal from hanging on ctrl+s

if [ -f ~/.bash_aliases ]; then source ~/.bash_aliases; fi

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
  if [ -f "~/.drush/drush.bashrc" ] ; then
    source ~/.drush/drush.bashrc
  fi
  if [ -f "~/.drush/drush.complete.sh" ] ; then
    source ~/.drush/drush.complete.sh
  fi
  if [ -f "/home/vagrant/.drush/drush.prompt.sh" ] ; then
    source ~/.drush/drush.prompt.sh
  fi

if [ -d ~/src ]; then cd ~/src; fi

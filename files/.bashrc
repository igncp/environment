bind '"\C-f":vi-fWord' > /dev/null 2>&1
bind '"\C-b":vi-bWord' > /dev/null 2>&1

stty -ixon # prevent the terminal from hanging on ctrl+s

if [ -f ~/.bash_aliases ]; then source ~/.bash_aliases; fi

if [[ -z $TMUX ]]; then TMUX_PREFIX="·"; else TMUX_PREFIX="£"; fi
PS1='${debian_chroot:+($debian_chroot)}\n\u@\h: \W$(__git_ps1) $TMUX_PREFIX '

alias ll="ls -lah"
alias rm="rm -rf"
alias mkdir="mkdir -p"
alias cp="cp -r"

export PATH=$PATH:/project/scripts
export PATH=$PATH:~/.local/bin

# nodenv
  export PATH=$PATH:/home/$USER/.nodenv/bin
  export PATH=$PATH:/home/$USER/.nodenv/versions/6.3.0/bin/
  eval "$(nodenv init -)"
  source <(npm completion)

# haskell
  alias runghc="stack exec runghc --silent -- -w -ihs"
  alias vim="stack exec vim"

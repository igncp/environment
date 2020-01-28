# mac-beginning START

set -e

mkdir -p ~/Library/KeyBindings/
chmod +x ~/project/provision/provision.sh

install_brew_package() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: brew install $PACKAGE"
    brew install "$PACKAGE"
  fi
}

install_brew_package the_silver_searcher ag
install_brew_package wget

cat > ~/Library/KeyBindings/DefaultKeyBinding.dict <<"EOF"
{
  /* Map # to § key*/
  "§" = ("insertText:", "#");
}
EOF

if [ ! -f ~/.git-prompt.sh ]; then
  curl -o ~/.git-prompt.sh \
      https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
fi

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi

cat > ~/.bashrc <<"EOF"
source ~/.git-prompt.sh

[ -z "$PS1" ] && return

export FZF_COMPLETION_TRIGGER='['
export FZF_DEFAULT_OPTS='--bind=pgup:preview-page-up,pgdn:preview-page-down,ctrl-j:preview-down,ctrl-k:preview-up --preview-window right:wrap'
AG_DIRS() { ag -u --hidden --ignore .git -g "" "$@" | xargs dirname | sort | uniq; }
export FZF_ALT_C_COMMAND="AG_DIRS"

source "/Users/igncp/.fzf/shell/key-bindings.bash"
source "/Users/igncp/.fzf/shell/completion.bash" 2> /dev/null

# Mac exclusive message
export BASH_SILENCE_DEPRECATION_WARNING=1

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$PATH:$HOME/nvim-osx64/bin"
export PATH="/Library/Developer/CommandLineTools/Library/Frameworks/Python3.framework/Versions/Current/bin:$PATH"
export PATH="/Library/Developer/CommandLineTools/usr/bin:$PATH"
export PATH="$PATH:/Users/igncp/.fzf/bin"
export PATH="$PATH:/Users/igncp/project/scripts/bootstrap"

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
fi

if [ -f ~/.bash_profile ]; then
      . ~/.bash_profile
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_PAPER=en_US.UTF-8
export LC_NAME=en_US.UTF-8
export LC_ADDRESS=en_US.UTF-8
export LC_TELEPHONE=en_US.UTF-8
export LC_MEASUREMENT=en_US.UTF-8
export LC_IDENTIFICATION=en_US.UTF-8
export LC_ALL=en_US.UTF-8

shopt -s histappend
bind 'revert-all-at-newline on'

# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

export EDITOR="vim"

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

export PATH=/opt/local/bin:$PATH # it must be ahead
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/project/provision"

# Enable Control + s and Control + q shortcuts for vim
stty -ixon

CHI_NUMBERS=(零 一 二 三 四 五 六 七 八 九)
getTime() {
  MINUTES=$(date +"%M"); HOURS=$(date +"%H")
  echo $HOURS":"$MINUTES
}
getCNumberWithTmux() {
  IDX=$(tmux display-message -p '#I'); echo "${CHI_NUMBERS[$IDX]}"
}

if [[ -z $TMUX ]]; then
  TMUX_PREFIX_A="" && TMUX_PREFIX_B="·"
else
  TMUX_PREFIX_A="\$(getCNumberWithTmux) " && TMUX_PREFIX_B=""
fi
get_jobs_prefix() {
  JOBS=$(jobs | wc -l)
  if [ "$JOBS" -eq "0" ]; then echo ""; else echo "${CHI_NUMBERS[$JOBS]} "; fi
}
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SSH_PS1_NOTICE="___SSH___ "
fi
PS1_BEGINNING="\n\n\[\e[33m\]$TMUX_PREFIX_A\[\e[36m\]$SSH_PS1_NOTICE\W\[\e[m\]"
PS1_MIDDLE="\[\e[32m\]\$(__git_ps1)\[\e[m\]\[\e[33m\] \$(get_jobs_prefix)\[\e[m\]"
PS1_END="\[\e[34m\]\$(getTime)\[\e[32m\]$TMUX_PREFIX_B\[\e[m\] "
export PS1="$PS1_BEGINNING""$PS1_MIDDLE""$PS1_END"
EOF

# mac-beginning END

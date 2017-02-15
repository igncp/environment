#!/usr/bin/env bash

# general START

if [ -d /project/scripts ]; then chmod -R +x /project/scripts; fi
if [ -f /project/provision/provision.sh ]; then chmod +x /project/provision/provision.sh; fi

mkdir -p ~/logs

if [ ! -f ~/.check-files/basic-packages ]; then
  echo "installing basic packages"
  sudo pacman -Syu --noconfirm
  sudo pacman -S archlinux-keyring --noconfirm
  sudo pacman -Su --noconfirm
  sudo pacman-db-upgrade
  sudo pacman -S --noconfirm ca-certificates-mozilla bash-completion
  # http://superuser.com/a/788480
  sudo sed -ir 's|^HOOKS=".*"$|HOOKS="base udev block autodetect modconf filesystems keyboard fsck"|' /etc/mkinitcpio.conf
  sudo mkinitcpio -p linux
  mkdir -p ~/.check-files && touch ~/.check-files/basic-packages
fi

install_pacman_package() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: sudo pacman -S --noconfirm $PACKAGE"
    sudo pacman -S --noconfirm "$PACKAGE"
  fi
}

download_cached() {
  URL=$1; FILE_NAME=$2; LOCATION=$3
  if [ ! -f /vm-shared/installs/"$FILE_NAME" ]; then
    mkdir -p ~/cached-download
    wget -O ~/cached-download/"$FILE_NAME" "$URL"
    mkdir -p /vm-shared/installs
    sudo mv ~/cached-download/"$FILE_NAME" /vm-shared/installs
    rm -rf ~/cached-download
  fi
  sudo cp /vm-shared/installs/"$FILE_NAME" "$LOCATION"
  sudo chown $USER "$LOCATION/$FILE_NAME"
}

install_pacman_package git
cat > ~/.gitconfig <<"EOF"
[user]
  email = foo@bar.com
  name = Foo Bar
[core]
  editor = vim
[alias]
  l = log --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %C(bold blue)%an %Cgreen%cd%Creset' --date=short
EOF
if [ ! -f /usr/local/bin/git-extras ]; then
  git clone https://github.com/tj/git-extras.git ~/.git-extras
  cd ~/.git-extras
  git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
  sudo make install
  cd ~ && rm -rf ~/.git-extras
fi

install_pacman_package ctags
install_pacman_package curl
install_pacman_package htop
install_pacman_package jq
install_pacman_package moreutils vidir
install_pacman_package ncdu
install_pacman_package strace
install_pacman_package tree
install_pacman_package unzip
install_pacman_package lsof

install_pacman_package netdata
if [[ ! -z $(sudo systemctl status netdata.service | grep inactive) ]]; then
  sudo systemctl restart netdata.service
fi

if [ ! -f ~/.acd_func ]; then
  sudo curl -o ~/.acd_func \
    https://raw.githubusercontent.com/djoot/all-bash-history/master/acd_func.sh
fi

if [ ! -f ~/.git-prompt ]; then
  sudo curl -o ~/.git-prompt \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
fi

if [ ! -d ~/src ]; then
  if [ -d /project/src ]; then cp -r /project/src ~; fi
fi

cat > ~/.bash_sources <<"EOF"
source_if_exists() {
  FILE_PATH=$1
  if [ -f $FILE_PATH ]; then source $FILE_PATH; fi
}

source_if_exists ~/.acd_func
source_if_exists ~/.bash_aliases
source_if_exists ~/.git-prompt
EOF

cat > ~/.bashrc <<"EOF"
# move from word to word. avoid ctrl+b to use in tmux
  bind '"\C-g":vi-fWord' > /dev/null 2>&1
  bind '"\C-f":vi-bWord' > /dev/null 2>&1

stty -ixon # prevent the terminal from hanging on ctrl+s

export HISTCONTROL=ignoreboth:erasedups
export EDITOR=vim

if [[ -z $TMUX ]]; then
  TMUX_PREFIX_A="" && TMUX_PREFIX_B="·"
else
  TMUX_PREFIX_A="{\$(tmux display-message -p '#I')} " && TMUX_PREFIX_B="£"
fi
get_jobs_prefix() {
  JOBS=$(jobs | wc -l)
  if [ "$JOBS" -eq "0" ]; then echo ""; else echo "[$JOBS] "; fi
}
PS1_BEGINNING="\n\[\e[34m\]\u\[\e[m\].\[\e[34m\]\h\[\e[m\]:\[\e[36m\] \W\[\e[m\]"
PS1_MIDDLE="\[\e[32m\]\$(__git_ps1)\[\e[m\]\[\e[33m\] \$(get_jobs_prefix)$TMUX_PREFIX_A\[\e[m\]"
PS1_END="\[\e[32m\]$TMUX_PREFIX_B\[\e[m\] "
export PS1="$PS1_BEGINNING""$PS1_MIDDLE""$PS1_END"

export PATH=$PATH:/project/scripts
export PATH=$PATH:/project/provision
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cabal/bin

source ~/.bash_sources

if [ "$(pwd)" = "/home/$USER" ]; then
  if [ -d ~/src ]; then cd ~/src; fi
fi
EOF

cat > ~/.bash_aliases <<"EOF"
alias cp="cp -r"
alias ll="ls -lah --color=always"
alias mkdir="mkdir -p"
alias rm="rm -rf"
alias tree="tree -a"

DisplayFilesConcatenated(){ xargs tail -n +1 | sed "s|==>|\n\n\n\n\n$1==>|; s|<==|<==\n|" | $EDITOR -; }
Find() { find "$@" ! -path "*node_modules*" ! -path "*.git*"; }
GetProcessUsingPort(){ fuser $1/tcp; }
MkdirCd(){ mkdir -p $1; cd $1; }
Popd(){ popd -n +"$1" > /dev/null; cd --; }
KillProcessUsingPort() { PID=$(lsof -i "tcp:$1" | awk 'NR!=1 {print $2}'); \
  if [[ ! -z $PID ]]; then echo "killing $PID"; sudo kill -9 $PID; fi; }
alias AliasesReload='source ~/.bash_aliases'
alias ConfigureTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias EditProvision="$EDITOR /project/provision/provision.sh && provision.sh"
alias Exit="\$(ps aux | grep tmux | grep -v grep | awk '{print $2}' | xargs kill) || exit"
alias LsTmpFiles='ls -laht /tmp | tac'
alias Sudo='sudo -E ' # this preserves aliases and environment in root
alias Tmux="tmux; exit"

alias GitStatus='git status -u'
GitOpenStatusFiles() { $EDITOR -p $(git status --porcelain $1 | grep -vE "^ D" | sed s/^...//); }
GitAdd() { git add -A $@; GitStatus; }
GitResetLastCommit() { LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B); \
  git reset --soft HEAD^; git add -A .; git commit -m "$LAST_COMMIT_MESSAGE"; }
alias GitAddAll='GitAdd .'
alias GitCommit='git commit -m'
alias GitEditorCommit='git commit -v'

UpdateSrc() {
  rm -rf /project/src
  rsync -av \
    --exclude='*node_modules*' \
    ~/src /project
}
EOF

cat > ~/.inputrc <<"EOF"
set show-all-if-ambiguous on
C-h:unix-filename-rubout
C-k:edit-and-execute-command
EOF

cat > ~/.tmux.conf <<"EOF"
set -g status off
set-window-option -g xterm-keys on

bind-key S-Left swap-window -t -1
bind-key S-Right swap-window -t +1

bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# keep your finger on ctrl, or don't
bind-key ^D detach-client

EOF

install_tmux_plugin() {
  REPO=$1; DIR=$(echo $REPO | sed -r "s|.+/(.+)|\1|") # foo/bar => bar
  if [ ! -d ~/.tmux/plugins/"$DIR" ]; then
    mkdir -p ~/.tmux/plugins
    git clone https://github.com/$REPO.git ~/.tmux/plugins/"$DIR"
  fi

  echo "set -g @plugin '$REPO'" >> ~/.tmux.conf
  # this line must be at the end of the config file
  sed -i "/run '~\/.tmux\/plugins\/tpm\/tpm'/ d" ~/.tmux.conf
  echo "run '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf
}

install_tmux_plugin tmux-plugins/tpm
install_tmux_plugin tmux-plugins/tmux-resurrect
install_tmux_plugin tmux-plugins/tmux-sessionist

cat > ~/.ctags <<"EOF"
--regex-make=/^([^# \t]*):/\1/t,target/
--langdef=markdown
--langmap=markdown:.mkd
--regex-markdown=/^#[ \t]+(.*)/\1/h,Heading_L1/
--regex-markdown=/^##[ \t]+(.*)/\1/i,Heading_L2/
--regex-markdown=/^###[ \t]+(.*)/\1/k,Heading_L3/
EOF

if ! type packer > /dev/null 2>&1 ; then
  rm -rf ~/packer
  mkdir ~/packer && cd ~/packer
  sudo pacman -S --noconfirm wget git expac jshon
  sudo wget https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=packer
  mv PKGBUILD?h=packer PKGBUILD
  makepkg
  sudo pacman --noconfirm -U packer-*
  cd ~ && rm -rf ~/packer
fi

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi
install_pacman_package the_silver_searcher ag
cat >> ~/.bashrc <<"EOF"
export FZF_COMPLETION_TRIGGER='['
AG_DIRS() { ag -u --hidden --ignore .git -g "" "$@" | xargs dirname | sort | uniq; }
export FZF_ALT_C_COMMAND="AG_DIRS"
EOF
# Ctrl+t binding breaks window when tmux + (n)vim + ctrl-z: no visible input. Disable it
sed -i "s|C-t|C-$|" ~/.fzf/shell/key-bindings.bash
sed -i "s|nvim n |nvim |; s|nvim |nvim n |" /home/vagrant/.fzf/shell/completion.bash
cat >> ~/.bash_sources <<"EOF"
source_if_exists ~/.fzf.bash
EOF

if [ ! -f ~/.config/up/up.sh ]; then
  curl --create-dirs -o ~/.config/up/up.sh https://raw.githubusercontent.com/shannonmoeller/up/master/up.sh
fi
echo 'source_if_exists ~/.config/up/up.sh' >> ~/.bash_sources

install_pacman_package task
cat >> ~/.bash_aliases <<"EOF"
alias t='task'
EOF
cat >> ~/.bash_sources <<"EOF"
source_if_exists /usr/share/doc/task/scripts/bash/task.sh # to have _task available
complete -o nospace -F _task t
EOF

# Search and Replace utility
  cat >> ~/.bash_aliases <<"EOF"
SR() { _CustomSR $1 && history -s $(cat /tmp/sr_replace) && history -s $(cat /tmp/sr_search); }
_CustomSR() {
  ask_with_default() {
    NAME="$1"; DEFAULT="$2"
    printf "$NAME [$DEFAULT]: " > /dev/stderr
    read VAR
    if [[ -z $VAR ]]; then VAR=$DEFAULT; fi
    echo "$VAR"
  }

  DIR_TO_FIND=${1:-.}
  echo "src: $DIR_TO_FIND"
  EXTRA_FIND_ARGS=$(ask_with_default "extra find arguments" "-name '*'")
  SEARCH_REGEX=$(ask_with_default "search regexp" "foo")
  REPLACEMENT_STR=$(ask_with_default "replacement str" "")
  CASE_SENSITIVE=$(ask_with_default "case sensitive" "yes")

  GREP_OPTS=""; SED_OPTS=""
  if [ "$CASE_SENSITIVE" != "yes" ]; then
    GREP_OPTS=" -i "; SED_OPTS="I"
  fi

  CMD_SEARCH="find $DIR_TO_FIND -type f $EXTRA_FIND_ARGS | xargs grep --color=always $GREP_OPTS -E "'"'"$SEARCH_REGEX"'" | less -R'
  CMD_REPLACE="find $DIR_TO_FIND -type f $EXTRA_FIND_ARGS | xargs grep $GREP_OPTS -El "'"'"$SEARCH_REGEX"'"'
  CMD_REPLACE="$CMD_REPLACE | xargs -I {} sed -i 's|$SEARCH_REGEX|$REPLACEMENT_STR|$SED_OPTS' {}"

  echo "$CMD_SEARCH" > /tmp/sr_search
  echo "$CMD_REPLACE" > /tmp/sr_replace
}
EOF

install_pacman_package shellcheck
echo 'SHELLCHECK_IGNORES="SC1090"' >> ~/.bashrc
add_shellcheck_ignores() {
  for DIRECTIVE in "$@"; do
    echo 'SHELLCHECK_IGNORES="$SHELLCHECK_IGNORES,SC'"$DIRECTIVE"'"' >> ~/.bashrc
  done
}
add_shellcheck_ignores 2016 2028 2046 2086 2143 2164
echo 'export SHELLCHECK_OPTS="-e $SHELLCHECK_IGNORES"' >> ~/.bashrc

install_pacman_package graphviz dot
cat >> ~/.bash_aliases <<"EOF"
DotPNGRecursive() {
  USED_DIR=${1:-.}
  echo "looking recursively in: $USED_DIR"
  find "$USED_DIR" -type f -name "*.dot" | while read FILE_PATH; do
    FNAME="${FILE_PATH::-4}" # remove extension
    dot "$FILE_PATH" -Tpng > "$FNAME".png
    echo "created $FNAME.png"
  done
}
EOF

# general END

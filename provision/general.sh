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

if ! type git > /dev/null 2>&1 ; then
  sudo pacman -S --noconfirm git
  git config --global user.email "foo@bar.com" && \
    git config --global user.name "Foo Bar" && \
    git config --global core.editor "vim"
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

install_pacman_package moreutils vidir
install_pacman_package ctags
install_pacman_package unzip
install_pacman_package curl
install_pacman_package tree
install_pacman_package htop
install_pacman_package jq
install_pacman_package ncdu

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

# shellcheck (without using stack, it takes a while to install)
  # if [ ! -f ~/.cabal/bin/shellcheck ]; then
  #   echo "installing shellcheck without using stack"
  #   sudo pacman -S --noconfirm cabal-install
  #   cabal update
  #   cabal install shellcheck
  # fi

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
  TMUX_PREFIX_A="{$(tmux display-message -p '#I')} " && TMUX_PREFIX_B="£"
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
alias ll="ls -lah"
alias mkdir="mkdir -p"
alias rm="rm -rf"
alias tree="tree -a"

DisplayFilesConcatenated(){ xargs tail -n +1 | sed "s|==>|\n\n\n\n\n$1==>|; s|<==|<==\n|" | $EDITOR -; }
Find() { find "$@" ! -path "*node_modules*" ! -path "*.git*"; }
GetProcessUsingPort(){ fuser $1/tcp; }
MkdirCd(){ mkdir -p $1; cd $1; }
Popd(){ popd -n +"$1" > /dev/null; cd --; }
alias AliasesReload='source ~/.bash_aliases'
alias ConfigureTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias EditProvision="$EDITOR /project/provision/provision.sh && provision.sh"
alias Exit="\$(ps aux | grep tmux | grep -v grep | awk '{print $2}' | xargs kill) || exit"
alias LsTmpFiles='ls -laht /tmp | tac'
alias Sudo='sudo -E ' # this preserves aliases and environment in root
alias Tmux="tmux; exit"

alias GitStatus='git status -u'
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
EOF

cat > ~/.tmux.conf <<"EOF"
set -g status off
set-window-option -g xterm-keys on

bind-key S-Left swap-window -t -1
bind-key S-Right swap-window -t +1

# keep your finger on ctrl, or don't
bind-key ^D detach-client
EOF

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

# general END

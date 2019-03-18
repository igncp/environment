#!/usr/bin/env bash

# set -o xtrace # displays commands, helpful for debugging errors

# general START

set -e

if [ ! -d /project ]; then
  sudo ln -s /media/sf_project /project
fi

if [ -d /project/scripts ]; then chmod -R +x /project/scripts; fi
if [ -f /project/provision/provision.sh ]; then chmod +x /project/provision/provision.sh; fi

mkdir -p ~/logs

install_ubuntu_package() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: sudo apt-get install -y $PACKAGE"
    sudo apt-get install -y "$PACKAGE"
  fi
}

install_ubuntu_package curl
install_ubuntu_package htop
install_ubuntu_package jq
install_ubuntu_package moreutils vidir
install_ubuntu_package ncdu
install_ubuntu_package tree
install_ubuntu_package unzip
install_ubuntu_package wget
install_ubuntu_package zip

if ! type git > /dev/null 2>&1 ; then
	sudo apt-get install -y git
fi
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

export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# prevent the terminal from hanging on ctrl+s
# although it can be recovered with ctrl+q
stty -ixon

export HISTCONTROL=ignoreboth:erasedups
export EDITOR=vim

getTime() {
  MINUTES=$(date +"%M"); HOURS=$(date +"%H")
  echo $HOURS":"$MINUTES
}
getCNumberWithTmux() {
  IDX=$(tmux display-message -p '#I'); echo "$IDX"
}

if [[ -z $TMUX ]]; then
  TMUX_PREFIX_A="" && TMUX_PREFIX_B="·"
else
  TMUX_PREFIX_A="\$(getCNumberWithTmux) " && TMUX_PREFIX_B=""
fi
get_jobs_prefix() {
  JOBS=$(jobs | wc -l)
  if [ "$JOBS" -eq "0" ]; then echo ""; else echo "$JOBS "; fi
}
PS1_BEGINNING="\n\n\[\e[33m\]$TMUX_PREFIX_A\[\e[36m\]\W\[\e[m\]"
PS1_MIDDLE="\[\e[32m\]\[\e[m\]\[\e[33m\] \$(get_jobs_prefix)\[\e[m\]"
PS1_END="\[\e[34m\]\$(getTime)\[\e[32m\] $TMUX_PREFIX_B\[\e[m\] "
export PS1="$PS1_BEGINNING"" UBUNTU ""$PS1_MIDDLE""$PS1_END"

export PATH=$PATH:/project/scripts
export PATH=$PATH:/project/scripts/bootstrap
export PATH=$PATH:/project/provision
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cabal/bin

source ~/.bash_sources
EOF

cat > ~/.bash_aliases <<"EOF"
alias cp="cp -r"
alias ll="ls -lah --color=always"
alias l="less -i"
alias mkdir="mkdir -p"
alias rm="rm -rf"
alias tree="tree -a"
alias ag="ag --hidden"
alias n="vim"

DisplayFilesConcatenated(){ xargs tail -n +1 | sed "s|==>|\n\n\n\n\n$1==>|; s|<==|<==\n|" | $EDITOR -; }
Find() { find "$@" ! -path "*node_modules*" ! -path "*.git*"; }
GetProcessUsingPort(){ fuser $1/tcp; }
MkdirCd(){ mkdir -p $1; cd $1; }
Popd(){ popd -n +"$1" > /dev/null; cd --; }
VisudoUser() { sudo env EDITOR=vim visudo -f /etc/sudoers.d/$1; }
ViDir() { find $@ | vidir -; }
RandomLine() { sort -R "$1" | head -n 1; }
KillProcessUsingPort() { PID=$(lsof -i "tcp:$1" | awk 'NR!=1 {print $2}'); \
  if [[ ! -z $PID ]]; then echo "killing $PID"; sudo kill -9 $PID; fi; }
SshGeneratePemPublicKey() { FILE=$1; ssh-keygen -f "$FILE" -e -m pem; }
FindLinesJustInFirstFile() { comm -23 <(sort "$1") <(sort "$2"); }
LineN() { head -n $1 | tail -n 1; }

alias AliasesReload='source ~/.bash_aliases'
alias CleanNCurses='stty sane;clear;'
alias ConfigureTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias EditProvision="$EDITOR /project/provision/provision.sh && provision.sh"
alias Exit="\$(ps aux | grep tmux | grep -v grep | awk '{print $2}' | xargs kill) || exit"
alias FDisk='sudo fdisk /dev/sda'
alias FilterLeaf=$'sort -r | awk \'a!~"^"$0{a=$0;print}\' | sort'
alias HierarchyManual='man hier'
alias Less="less -i"
alias LsTmpFiles='ls -laht /tmp | tac'
alias PacmanUpdateRepos='sudo pacman -Sy'
alias PathShow='echo $PATH | tr ":" "\n" | sort | uniq | less'
alias RsyncDelete='rsync -rhv --delete' # remember to add a slash at the end of source (dest doesn't matter)
alias Sudo='sudo -E ' # this preserves aliases and environment in root
alias Tee="tee /dev/tty";
alias Tmux="tmux attach; exit"
alias Visudo='sudo env EDITOR=vim visudo'
alias Xargs='xargs -I{}'

alias GitStatus='git status -u'
GitOpenStatusFiles() { $EDITOR -p $(git status --porcelain $1 | grep -vE "^ D" | sed s/^...//); }
GitAdd() { git add -A $@; GitStatus; }
GitResetLastCommit() { LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B); \
  git reset --soft HEAD^; git add -A .; git commit -m "$LAST_COMMIT_MESSAGE"; }
alias GitAddAll='GitAdd .'
alias GitCommit='git commit -m'
alias GitEditorCommit='git commit -v'
alias GitRebaseResetAuthorContinue='git commit --amend --reset-author --no-edit; git rebase --continue'
alias GitBranchOrder='git branch -r --sort=creatordate --format "%(creatordate:relative);%(committername);%(refname:lstrip=-1)" | grep -v ";HEAD$" | column -s ";" -t | tac | less'
alias GitListConflictFiles='git diff --name-only --diff-filter=U'
alias GitListFilesChangedHistory='git log --pretty=format: --name-only | sort | uniq -c | sort -rg' # can add `--author Foo`, --since, or remove files

alias RemoveAnsiColors="sed 's/\x1b\[[0-9;]*m//g'"
alias Ports='sudo netstat -tulanp'
alias Headers='curl -I' # e.g. Headers google.com
alias TopMemory='ps auxf | sort -nr -k 4 | head -n' # e.g. TopMemory 10
alias ChModRX='chmod -R +x'
EOF

cat > ~/.inputrc <<"EOF"
set show-all-if-ambiguous on
C-h:unix-filename-rubout
C-k:edit-and-execute-command

"\e[A": history-search-backward
"\e[B": history-search-forward
EOF

if [ ! -f /project/.gitignore ]; then
  cat > /project/.gitignore <<"EOF"
/*

!/provision
!.gitignore
!scripts/
!vim-custom-snippets/
EOF
fi

if [ ! -f ~/.dircolors ]; then
  dircolors -p > ~/.dircolors
  sed -i 's|^OTHER_WRITABLE 34;42|OTHER_WRITABLE 34;4|' ~/.dircolors
fi

echo 'eval "$(dircolors ~/.dircolors)"' >> ~/.bashrc

# general END

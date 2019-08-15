#!/usr/bin/env bash

# set -o xtrace # displays commands, helpful for debugging errors

# general START

set -e

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

install_from_aur() {
  CMD_CHECK="$1"; REPO="$2"
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR"
    git clone "$REPO"
    cd ./*
    makepkg -si --noconfirm
    cd; rm -rf "$TMP_DIR"
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

install_pacman_package base-devel make
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

install_pacman_package 'net-tools' netstat
install_pacman_package alsa-utils alsamixer # for audio
install_pacman_package at
install_pacman_package ctags
install_pacman_package curl
install_pacman_package feh # image previews
install_pacman_package jq
install_pacman_package lsof
install_pacman_package moreutils vidir
install_pacman_package ncdu
install_pacman_package ranger
install_pacman_package rsync
install_pacman_package strace
install_pacman_package tree
install_pacman_package unzip
install_pacman_package wget
install_pacman_package zip

# https://www.thegeekstuff.com/2011/09/linux-htop-examples
install_pacman_package htop

sudo atd

install_pacman_package netdata
if [[ ! -z $(sudo systemctl status netdata.service | grep inactive) ]]; then
  sudo systemctl restart netdata.service
fi

if [ ! -f ~/.acd_func ]; then
  curl -o ~/.acd_func \
    https://raw.githubusercontent.com/djoot/all-bash-history/master/acd_func.sh
fi

if [ ! -f ~/.git-prompt ]; then
  curl -o ~/.git-prompt \
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

export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# prevent the terminal from hanging on ctrl+s
# although it can be recovered with ctrl+q
stty -ixon

export HISTCONTROL=ignoreboth:erasedups
export EDITOR=vim

# add this in custom provisioning with:
# sed -i '1iWITH_CANTO_WORD=1' ~/.bashrc
CANTO_WORD=""
if [[ $WITH_CANTO_WORD -eq 1 ]]; then
  if [ ! -f ~/canto.txt ]; then
    echo "You must copy environment/other/canto.txt to ~/canto.txt"
  else
    CANTO_WORD=" $(cat ~/canto.txt | shuf -n 1)"
  fi
fi

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

export PATH=$PATH:/project/scripts
export PATH=$PATH:/project/scripts/bootstrap
export PATH=$PATH:/project/provision
export PATH=$PATH:~/.local/bin
export PATH=$PATH:~/.cabal/bin

source ~/.bash_sources

GetCurrentCantoCharMeaning() {
  CANTO_CHAR=$(echo "$CANTO_WORD" | grep -o '^.')
  printf "requesting: $CANTO_CHAR\n\n"
  curl http://www.cantonese.sheik.co.uk/scripts/wordsearch.php?level=0 -X POST \
    -d "TEXT=$CANTO_CHAR&SEARCHTYPE=0&radicaldropdown&searchsubmit=1" > /tmp/cantodict-result.txt
  printf "curl response saved in: /tmp/cantodict-result.txt\n\n"
  cat /tmp/cantodict-result.txt | grep -Eo 'http:.*?characters\/[0-9]*\/' | head -n 1
}
EOF

cat > ~/.bash_aliases <<"EOF"
alias ag="ag --hidden"
alias cp="cp -r"
alias l="less -i"
alias ll="ls -lah --color=always"
alias mkdir="mkdir -p"
alias rm="rm -rf"
alias tree="tree -a"
alias r="ranger"

AgN() { ag -l "$@" | xargs "$EDITOR" -p; }
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
WatchBattery() { watch -n0 cat /sys/class/power_supply/BAT0/capacity; }

alias AliasesReload='source ~/.bash_aliases'
alias CleanNCurses='stty sane;clear;'
alias ConfigureTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias EditProvision="$EDITOR /project/provision/provision.sh && provision.sh"
alias Exit="\$(ps aux | grep tmux | grep -v grep | awk '{print $2}' | xargs kill) || exit"
alias FDisk='sudo fdisk /dev/sda'
alias FilterLeaf=$'sort -r | awk \'a!~"^"$0{a=$0;print}\' | sort'
alias HierarchyManual='man hier'
alias LastColumn="awk '{print "'$NF'"}'"
alias Less="less -i"
alias LsTmpFiles='ls -laht /tmp | tac'
alias PacmanUpdateRepos='sudo pacman -Sy'
alias PathShow='echo $PATH | tr ":" "\n" | sort | uniq | less'
alias RsyncDelete='rsync -rhv --delete' # remember to add a slash at the end of source (dest doesn't matter)
alias Sudo='sudo -E ' # this preserves aliases and environment in root
alias SystemInfo='sh ~/.system-info.sh'
alias Tee="tee /dev/tty";
alias TimeRestartService='sudo systemctl restart systemd-timesyncd.service'
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
EOF

cat > ~/.system-info.sh <<"EOF"
clear
echo ""
echo "Battery: $(cat /sys/class/power_supply/BAT0/capacity)%"
echo "Time: $(date)"
EOF
chmod +x ~/.system-info.sh

install_pacman_package tmux
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

set -wg mode-style bg=black,fg=blue
set-option -g message-bg black
set-option -g message-fg white

new-session -n $HOST

set -g @copycat_search_C-t '\.test\.js:[0-9]'
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
install_tmux_plugin tmux-plugins/tmux-copycat

if [ ! -f ~/.tmux-completion.sh ]; then
  wget https://raw.githubusercontent.com/Bash-it/bash-it/4e730eb9a15c/completion/available/tmux.completion.bash \
    -O ~/.tmux-completion.sh
fi
echo 'source_if_exists ~/.tmux-completion.sh' >> ~/.bashrc

cat > ~/.ctags <<"EOF"
--regex-make=/^([^# \t]*):/\1/t,target/
--langdef=markdown
--langmap=markdown:.mkd
--regex-markdown=/^#[ \t]+(.*)/\1/h,Heading_L1/
--regex-markdown=/^##[ \t]+(.*)/\1/i,Heading_L2/
--regex-markdown=/^###[ \t]+(.*)/\1/k,Heading_L3/
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

install_pacman_package shellcheck
echo 'SHELLCHECK_IGNORES="SC1090"' >> ~/.bashrc
add_shellcheck_ignores() {
  for DIRECTIVE in "$@"; do
    echo 'SHELLCHECK_IGNORES="$SHELLCHECK_IGNORES,SC'"$DIRECTIVE"'"' >> ~/.bashrc
  done
}
add_shellcheck_ignores 2016 2028 2046 2059 2086 2088 2143 2164 2181 1117
echo 'export SHELLCHECK_OPTS="-e $SHELLCHECK_IGNORES"' >> ~/.bashrc

install_pacman_package graphviz dot
cat > ~/.dot-script.sh <<"EOF2"
  FILE_PATH=$1
  EXTENSION=$2
  FNAME="${FILE_PATH::-4}" # remove .dot extension
  RELATIVE=$(python -c "import os.path; print(os.path.relpath('$FNAME', '$PWD'))")
  dot "$FILE_PATH" -T"$EXTENSION" > "$FNAME"."$EXTENSION" && \
  printf "created ${GREEN}$RELATIVE."$EXTENSION"${NC}\n"
EOF2
chmod +x ~/.dot-script.sh
cat >> ~/.bash_aliases <<"EOF"
_DotRecursiveWatch() {
  EXTENSION=$1
  USED_DIR=${2:-.}
  printf "looking recursively in: ${BLUE}$USED_DIR${NC}\n"
  while true; do # when a file is added, entr will exit
    sleep 1
    find "$USED_DIR" -type f -name "*.dot" | entr -d ~/.dot-script.sh /_ "$EXTENSION"
  done
}
DotPNGRecursiveWatch() {
  _DotRecursiveWatch png $@
}
DotSVGRecursiveWatch() {
  _DotRecursiveWatch svg $@
}
DotJPGRecursiveWatch() {
  _DotRecursiveWatch jpg $@
}
EOF

cat > ~/.m4-script.sh <<"EOF2"
  FILE_PATH="$1"
  RESULT_EXTENSION="$2"
  FNAME="${FILE_PATH::-3}" # remove .m4 extension
  RELATIVE=$(python -c "import os.path; print(os.path.relpath('$FNAME', '$PWD'))")
  m4 "$FILE_PATH" > "$FNAME"."$RESULT_EXTENSION" && \
  printf "created ${GREEN}$RELATIVE."$RESULT_EXTENSION"${NC}\n"
EOF2
chmod +x ~/.m4-script.sh
cat >> ~/.bash_aliases <<"EOF"
M4RecursiveWatch() {
  RESULT_EXTENSION="$1"
  USED_DIR="${2:-.}"
  printf "looking recursively in: ${BLUE}$USED_DIR${NC}\n"
  while true; do # when a file is added, entr will exit
    sleep 1
    find "$USED_DIR" -type f -name "*.m4" | entr -d ~/.m4-script.sh /_ "$RESULT_EXTENSION"
  done
}
EOF

if ! type entr > /dev/null 2>&1 ; then
  sudo rm -rf ~/_entr-tmp
  cd ~ && mkdir ~/_entr-tmp && cd ~/_entr-tmp
  curl -O https://bitbucket.org/eradman/entr/get/entr-3.6.tar.gz
  tar -zxvf ./*.tar.gz
  ENTR_DIR=$(find . -maxdepth 1 -mindepth 1 -type d) && cd $ENTR_DIR
  ./configure && make test && sudo make install
  cd ~ && sudo rm -rf ~/_entr-tmp
fi

check_file_exists() {
  FILE=$1
  if [ ! -f "$FILE" ]; then
    echo "This provision depends on the file: $1 . Will exit now."
    exit 1
  fi
}

# fzf
  if [ ! -d ~/.fzf ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
  fi
  install_pacman_package the_silver_searcher ag
  cat >> ~/.bashrc <<"EOF"
  export FZF_COMPLETION_TRIGGER='['
  export FZF_DEFAULT_OPTS='--bind=pgup:preview-page-up,pgdn:preview-page-down,ctrl-j:preview-down,ctrl-k:preview-up --preview-window right:wrap'
  AG_DIRS() { ag -u --hidden --ignore .git -g "" "$@" | xargs dirname | sort | uniq; }
  export FZF_ALT_C_COMMAND="AG_DIRS"
EOF
  # Ctrl+t binding breaks window when tmux + (n)vim + ctrl-z: no visible input. Disable it
  sed -i "s|C-t|C-$|" ~/.fzf/shell/key-bindings.bash
  cat >> ~/.bash_sources <<"EOF"
  source_if_exists ~/.fzf.bash
EOF

  mkdir -p /project/scripts/custom

  cat >> ~/.bash_aliases <<"EOF"
  __FZFBookmarkedCommands() {
    cat ~/.bookmarked-commands |
    fzf --height 100% --border -m --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
  }
  __FZFScripts() {
    $(find /project/scripts -type f ! -name "*.md" |
    fzf --height 100% --border -m -q "'" --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort')
  }

  bind '"\er": redraw-current-line'
  bind '"\C-q\C-q": "$(__FZFBookmarkedCommands)\e\C-e\er"'
  bind '"\C-q\C-w": "$(__FZFBookmarkedCommands)\e\C-e\er\n"'
  bind '"\C-q\C-a": "$(__FZFScripts)\e\C-e\er"'
  bind '"\C-q\C-s": "$(__FZFScripts)\e\C-e\er\n"'
EOF
  cat > ~/.bookmarked-commands <<"EOF"
    GitCommit ""
    GitEditorCommit
    GitStatus
    GitAddAll
    GitDiff HEAD -- ':!*package-lock.json' ':!*yarn.lock' | diff-so-fancy | less -R
    git checkout -b
    tmux kill-session -t
    git l
    git fetch
    cp .git/COMMIT_EDITMSG /tmp/COMMIT_EDITMSG
    (alias ; typeset -f) | NFZF
    git commit -m "$(head .git/COMMIT_EDITMSG  -n 1)"
EOF

if [ ! -f ~/hhighlighter/h.sh ] > /dev/null 2>&1 ; then
  rm -rf ~/hhighlighter
  git clone --depth 1 https://github.com/paoloantinori/hhighlighter.git ~/hhighlighter
fi
echo 'source_if_exists ~/hhighlighter/h.sh' >> ~/.bash_sources

if [ ! -f ~/.dircolors ]; then
  dircolors -p > ~/.dircolors
  sed -i 's|^OTHER_WRITABLE 34;42|OTHER_WRITABLE 34;4|' ~/.dircolors
fi

echo 'eval "$(dircolors ~/.dircolors)"' >> ~/.bashrc

if ! type sr > /dev/null 2>&1 ; then
  cd ~; rm -rf sr-tmp
  git clone https://github.com/igncp/sr.git sr-tmp --depth 1
  cd sr-tmp
  make
  sudo mv build/bin/sr /usr/bin
  cd ~ ; rm -rf sr-tmp
fi

# for gng2 key generation: sudo rngd -r /dev/urandom
install_pacman_package rng-tools rngd

cat > /tmp/choose_session.sh <<"EOF"
#!/usr/bin/env bash

SESSION=$(tmux ls | grep -o '^.*: ' | sed 's|: ||' | fzf)

if [ -z "$SESSION" ]; then exit 0; fi

tmux switch-client -t "$SESSION"
EOF
echo "bind b split-window 'sh /tmp/choose_session.sh'" >> ~/.tmux.conf

if [ ! -d /project/.git ]; then
  (cd /project && git init)
fi

if [ ! -f /project/.gitignore ]; then
  cat > /project/.gitignore <<"EOF"
/*

!/provision
!.gitignore
!scripts/
!vim-custom-snippets/
EOF
fi

cat >> ~/.bash_aliases <<"EOF"
UpdateProvisionRepo() {
  cd /project; git add -A .; git diff HEAD; git status
  read -p "If you are sure, press y: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[y]$ ]]; then
    git commit -m "Update repo"; git push origin master
  fi
  cd -
}
EOF

# general END

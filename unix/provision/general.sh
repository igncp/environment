# general START

if [ ! -f ~/project/.config/ssh-notice-color ]; then
  echo 'cyan' > ~/project/.config/ssh-notice-color
fi

cat >> ~/.shellrc <<"EOF"
getTime() {
  MINUTES=$(date +"%M"); HOURS=$(date +"%H")
  echo $HOURS":"$MINUTES
}
getCNumberWithTmux() {
  IDX=$(tmux display-message -p '#I'); echo "$IDX"
}

if [[ -z $TMUX ]]; then
  TMUX_PREFIX_A="" && TMUX_PREFIX_B=" ·"
else
  TMUX_PREFIX_A='$(getCNumberWithTmux) ' && TMUX_PREFIX_B=''
fi
get_jobs_prefix() {
  JOBS=$(jobs | wc -l | sed 's|\s*||')
  if [ "$JOBS" -eq "0" ]; then echo ""; else echo "$JOBS "; fi
}
SSH_PS1_NOTICE_COLOR="$(cat ~/project/.config/ssh-notice-color)"
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
  if [ ! -f ~/project/.config/ssh-notice ]; then
    echo "~/project/.config/ssh-notice is missing, using the default"
    SSH_PS1_NOTICE="[SSH] "
  else
    FILE_CONTENT="$(cat ~/project/.config/ssh-notice)"
    if [ -z "$FILE_CONTENT" ]; then
      SSH_PS1_NOTICE="[VM] "
    else
      SSH_PS1_NOTICE="[$FILE_CONTENT] "
    fi
  fi
fi
EOF

if [ -d ~/project/scripts ]; then chmod -R +x ~/project/scripts; fi
if [ -f ~/project/provision/provision.sh ]; then chmod +x ~/project/provision/provision.sh; fi

mkdir -p ~/logs

install_system_package base-devel make
install_system_package git
cat > ~/.gitconfig <<"EOF"
[user]
  email = foo@bar.com
  name = Foo Bar
[core]
  editor = vim
[alias]
  l = log --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %C(bold blue)%an %Cgreen%cd%Creset' --date=short
[color "diff-highlight"]
	oldNormal = "#bb0000"
	oldHighlight = "#bb0000 reverse"
	newNormal = "#009900"
	newHighlight = "#009900 reverse"
[color "diff"]
	meta = "#0000cc"
	frag = "#333333 #dddddd"
	func = "#666666 #dddddd"
	old = "#bb0000"
	new = "#009900"
	whitespace = "#0000ff reverse"
EOF
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|meta =.*|meta = "#ffff77"|' ~/.gitconfig
  sed -i 's|old =.*|old = "#d67a6f"|' ~/.gitconfig
  sed -i 's|new =.*|new = "#bdffcd"|' ~/.gitconfig
  sed -i 's|oldNormal =.*|oldNormal = "#d67a6f"|' ~/.gitconfig
  sed -i 's|oldHighlight =.*|oldHighlight = "#d67a6f reverse"|' ~/.gitconfig
  sed -i 's|newNormal =.*|newNormal = "#bdffcd"|' ~/.gitconfig
  sed -i 's|newHighlight =.*|newHighlight = "#bdffcd reverse"|' ~/.gitconfig
fi
git config --global pull.rebase false
if [ ! -f /usr/local/bin/git-extras ]; then
  git clone https://github.com/tj/git-extras.git ~/.git-extras
  cd ~/.git-extras
  git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
  sudo make install
  cd ~ && rm -rf ~/.git-extras
fi

install_system_package curl
install_system_package dnsutils dig
install_system_package jq
install_system_package lsof
install_system_package moreutils vidir
install_system_package ncdu
install_system_package neofetch
install_system_package net-tools netstat
install_system_package nmap
install_system_package ranger
install_system_package rsync
install_system_package tree
install_system_package unzip
install_system_package wget
install_system_package zip

# https://github.com/TomWright/dasel
# https://daseldocs.tomwright.me/
if ! type dasel > /dev/null 2>&1 ; then
  if [ "$PROVISION_OS" == "MAC" ]; then
    brew install dasel
  elif [ "$PROVISION_OS" == "LINUX" ]; then
    FILTER_OPT="linux_amd64"
    DASEL_URL="$(curl -sSLf https://api.github.com/repos/tomwright/dasel/releases/latest | grep browser_download_url | grep "$FILTER_OPT" | grep -v '\.gz' | cut -d\" -f 4)"
    curl -sSLf "$DASEL_URL" -L -o dasel && sudo chmod +x dasel
    sudo mv ./dasel /usr/local/bin/dasel
  fi
fi

if [ ! -f ~/.git-prompt ]; then
  if type pacman > /dev/null 2>&1 ; then
    sudo pacman -S --noconfirm bash-completion
  fi
  curl -o ~/.git-prompt \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
fi

cat >> ~/.shell_sources <<"EOF"
source_if_exists() {
  FILE_PATH=$1
  if [ -f $FILE_PATH ]; then source $FILE_PATH; fi
}

source_if_exists ~/.shell_aliases
source_if_exists ~/.git-prompt
EOF

cat >> ~/.bash_profile <<"EOF"
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
EOF

cat >> ~/.bashrc <<"EOF"
if [ -z "$PS1" ]; then
  # prompt var is not set, so this is *not* an interactive shell (e.g. using scp)
  return
fi

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

source ~/.shellrc
source ~/.shell_sources

PS1_BEGINNING="\n\n\[\e[33m\]$TMUX_PREFIX_A"
PS1_NEXT="\[\e[36m\]$SSH_PS1_NOTICE\W\[\e[m\]"
PS1_MIDDLE="\[\e[32m\]\$(__git_ps1)\[\e[m\]\[\e[33m\] \$(get_jobs_prefix)\[\e[m\]"
PS1_END="\[\e[34m\]\$(getTime)\[\e[32m\]$TMUX_PREFIX_B\[\e[m\] "
export PS1="$PS1_BEGINNING""$PS1_NEXT""$PS1_MIDDLE""$PS1_END"
EOF

cat >> ~/.shellrc <<"EOF"
export EDITOR=vim
export PATH="$PATH:$HOME/project/scripts"
export PATH="$PATH:$HOME/project/scripts/bootstrap"
export PATH="$PATH:$HOME/project/provision"
export PATH="$PATH:$HOME/.local/bin"
EOF

cat >> ~/.shell_aliases <<"EOF"
alias ag="ag --hidden  --color-match 7"
alias agg='ag --hidden --ignore node_modules --ignore .git'
alias cp="cp -r"
alias htop="htop --no-color"
alias l="less -i"
alias ll="ls -lah --color=always"
alias lsblk="lsblk -f"
alias mkdir="mkdir -p"
alias r="ranger"
alias rm="rm -rf"
alias tree="tree -a"

alias Lsblk="lsblk -f | less -S"
Diff() { diff --color=always "$@" | less -r; }
DisplayFilesConcatenated(){ xargs tail -n +1 | sed "s|==>|\n\n\n\n\n$1==>|; s|<==|<==\n|" | $EDITOR -; }
FileSizeCreate() { head -c "$1" /dev/urandom > "$2"; } # For example: FileSizeCreate 1GB /tmp/foo
FindLinesJustInFirstFile() { comm -23 <(sort "$1") <(sort "$2"); }
FindSortDate() { find "$@" -printf "%T@ %Tc %p\n" | sort -nr; }
GetProcessUsingPort(){ fuser $1/tcp 2>&1 | grep -oE '[0-9]*$'; }
GetProcessUsingPortAndKill(){ fuser $1/tcp 2>&1 | grep -oE '[0-9]*$' | xargs -I {} kill {}; }
KillPsAux() { awk '{ print $2 }' | xargs -I{} kill "$@" {}; }
LsofDir() { lsof +D $1; } # It uses `+` instead of `-`
LsofNetwork() { lsof -i; }
LsofPort() { lsof -i TCP:$1; }
LsofProcess() { lsof -p $1; } # It expects the PID
RandomFile() { find "$1" -type f | shuf -n 1; }
RandomLine() { sort -R "$1" | head -n 1; }
# will not catch `'` so can wrap generated texts with single quotes
RandomStrGenerator() { tr -dc 'A-Za-z0-9!"#$%&()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c "$1"; echo; }
SedLines() { if [ "$#" -eq 1 ]; then sed -n "$1,$1p"; else sed -n "$1,$2p"; fi; }
TopCPU()    { ps aux | sort -nr -k 3 | head "$@" | sed -e 'G;G;'; } # e.g. TopCPU -n 5 | less -S
TopMemory() { ps aux | sort -nr -k 4 | head "$@" | sed -e 'G;G;'; } # e.g. TopMemory -n 5 | less -S
USBClone() { if [ -z "$I" ] || [ -z "$O" ]; then echo "Missing params"; return; fi; dd if=$I of=$O bs=1G count=10 status=progress; } # Example: I=/dev/sdb O=/dev/sdc USBClone
Vidir() { vidir -v -; }
VidirFind() { find $@ | vidir -v -; }
VisudoUser() { sudo env EDITOR=vim visudo -f /etc/sudoers.d/$1; }

alias SSHAgent='eval `ssh-agent`'
SSHGeneratePemPublicKey() { FILE=$1; ssh-keygen -f "$FILE" -e -m pem; }
SSHGenerateStrongKey() { FILE="$1"; ssh-keygen -t ed25519 -f "$FILE"; }
alias SSHListLocalForwardedPorts='ps x -ww -o pid,command | ag ssh | grep --color=never localhost'
SSHForwardPortLocal() { ssh -fN -L "$1":localhost:"$1" ${@:2}; } # SSHForwardPort 1234 192.168.1.40
alias SSHDConfig='sudo sshd -T'

alias AliasesReload='source ~/.shell_aliases'
alias CleanNCurses='stty sane;clear;'
alias EditProvision="$EDITOR ~/project/provision/provision.sh && provision.sh"
alias FDisk='sudo fdisk /dev/sda'
alias FilterLeaf=$'sort -r | awk \'a!~"^"$0{a=$0;print}\' | sort'
alias HierarchyManual='man hier'
alias IPPublic='curl ifconfig.co'
alias LastColumn="awk '{print "'$NF'"}'"
alias PathShow='echo $PATH | tr ":" "\n" | sort | uniq | less'
alias PsTree='pstree -pTUl | less -S'
alias RsyncDelete='rsync -rhv --delete' # remember to add a slash at the end of source (dest doesn't matter)
alias ShellChangeToBash='chsh -s /bin/bash; exit'
alias SocketSearch='sudo ss -lntup'
alias Sudo='sudo -E ' # this preserves aliases and environment in root
alias TreeDir='tree -d'
alias Visudo='sudo env EDITOR=vim visudo'
alias Xargs='xargs -I{}'

alias CrontabUser='crontab -e'
alias CrontabRoot='sudo EDITOR=vim crontab -e'

GitAdd() { git add -A $@; git status -u; }
GitFilesAddedDiff() {
  GitAddAll 2>&1 > /dev/null;
  R_PATH="$(git rev-parse --show-toplevel)";
  git diff --name-only --diff-filter=A "$@" | sed 's|^|'"$R_PATH"'/|';
}
GitDiff() { git diff --color --relative $@; }
GitsShow() { git show --color $@; }
GitOpenStatusFiles() { $EDITOR -p $(git status --porcelain $1 | grep -vE "^ D" | sed s/^...//); }
GitPrintRemoteUrl() { git config --get "remote.${1:-origin}.url"; }
GitResetLastCommit() { LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B); \
  git reset --soft HEAD^; git add -A .; git commit -m "$LAST_COMMIT_MESSAGE"; }
GitRevertCode() { git reset "$1"; rm -rf "$1" ; git checkout -- "$1"; git status; }
GitFilesByAuthor() {
  DEFAULT_AUTHOR="$(git config user.name)"; AUTHOR="${1:-$DEFAULT_AUTHOR}"
  git log \
    --pretty="%H" \
    --author="$AUTHOR" \
  | while read commit_hash; do \
      git show --oneline --name-only $commit_hash | tail -n+2; \
    done \
  | sort | uniq | grep .
}
GitFilesByAuthorLatest() {
  git ls-files -z "$@" | \
    xargs --null -I % \
      sh -c "printf %' '; git annotate -p % | sed -nr '/^author /{s/^author (.*)/\1/;p}' | sort | uniq | awk '{printf (\$0 \" \")}END{print \"\"}'"
}
GitFilesByAuthorLatestGrep() {
  GitFilesByAuthorLatest "${@:2}" | grep -i "$1" | grep -o '^[^ ]* '
}

alias GitAddAll='GitAdd .'
alias GitBranchOrder='git branch -r --sort=creatordate --format "%(creatordate:relative);%(committername);%(refname)" | sed "s|refs/remotes/origin/||" | grep -v ";HEAD$" | column -s ";" -t | tac | less'
alias GitCommit='git commit -m'
alias GitConfig='"$EDITOR" .git/config'
alias GitEditorCommit='git commit -v'
alias GitListConflictFiles='git diff --name-only --relative --diff-filter=U'
alias GitListFilesChangedHistory='git log --pretty=format: --name-only | sort | uniq -c | sort -rg' # can add `--author Foo`, --since, or remove files
alias GitRebaseResetAuthorContinue='git commit --amend --reset-author --no-edit; git rebase --continue'
alias GitStashApply='git stash apply' # can also use name here
alias GitStashList='git stash list'
alias GitStashName='git stash push -m'
alias GitSubmodulesUpdate='git submodule update --init --recursive' # clones existing submodules

alias Headers='curl -I' # e.g. Headers google.com
alias NmapLocal='sudo nmap -sn 192.168.1.0/24 > /tmp/nmap-result && sed -i "s|Nmap|\nNmap|" /tmp/nmap-result && less /tmp/nmap-result'
alias Ports='sudo netstat -tulanp'
alias NetstatConnections='netstat -nputw'
alias RemoveAnsiColors="sed 's/\x1b\[[0-9;]*m//g'"

WorktreeClone() { git clone --bare "$1" .bare; echo "gitdir: ./.bare" > .git; }
EOF

cat > ~/.inputrc <<"EOF"
set mark-symlinked-directories on
set show-all-if-ambiguous on

C-h:unix-filename-rubout
C-k:edit-and-execute-command

Control-x: " fg\n"
Control-}: " | less -SR\n"

set show-all-if-ambiguous on

# How to get these characters:
# - run `sed -n l`
# - type combination (it only works for some, like ctrl + something)
# - copy it here, but replace ^[ with  (ctrl-v ctrl-[ in insert mode)
"[1;5A":menu-complete # ctrl-up
"[1;5B":menu-complete-backward # ctrl-down
EOF

install_system_package tmux
cat > ~/.tmux.conf <<"EOF"
set-option -g default-shell $SHELL
set -s escape-time 0
set-window-option -g xterm-keys on

set -g status off
set -g status-right ""
set -g status-left ' [#(echo "$TMUX" | cut -f1 -d"," | sed -E "s|(/private)?/tmp/tmux-[0-9]*/||")]'
set -g status-left-length 50
set -g window-status-current-format ''
set -g window-status-format ''
set status-utf8 on
set utf8 on
set -g default-terminal "screen-256color"
set -g status-bg black
set -g status-fg red

bind-key S-Left swap-window -t -1
bind-key S-Right swap-window -t +1

bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# cycle through the panes in the window
bind -r Tab select-pane -t :.+

# keep your finger on ctrl, or don't
bind-key ^D detach-client

set -wg mode-style bg=white,fg=darkblue
set -wg message-style bg=white,fg=darkblue
set -wg mode-keys vi

new-session -n $HOST

set -g @copycat_search_C-t '\.test\.js:[0-9]'

unbind-key -T copy-mode-vi v
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
bind-key -T copy-mode-vi 'y' send -X copy-selection
bind-key -T copy-mode-vi 'd' send -X clear-selection
EOF

if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|=white|=black|' ~/.tmux.conf
  sed -i 's|=darkblue|=lightblue|' ~/.tmux.conf
fi

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

if [ -f /tmp/tmux_bootstrap_bindings.txt ]; then
  cat /tmp/tmux_bootstrap_bindings.txt >> ~/.tmux.conf
fi

if [ ! -f ~/.tmux-completion.sh ]; then
  wget https://raw.githubusercontent.com/Bash-it/bash-it/4e730eb9a15c/completion/available/tmux.completion.bash \
    -O ~/.tmux-completion.sh
fi
echo 'source_if_exists ~/.tmux-completion.sh' >> ~/.bashrc

if [ ! -f ~/.config/up/up.sh ]; then
  curl --create-dirs -o ~/.config/up/up.sh https://raw.githubusercontent.com/shannonmoeller/up/master/up.sh
fi
echo 'source_if_exists ~/.config/up/up.sh' >> ~/.shell_sources

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
  install_system_package the_silver_searcher ag
  cat >> ~/.shellrc <<"EOF"
  export FZF_COMPLETION_TRIGGER='['
  export FZF_DEFAULT_OPTS='--bind=pgup:preview-page-up,pgdn:preview-page-down,ctrl-j:preview-down,ctrl-k:preview-up --preview-window right:wrap --color=light'
  AG_DIRS() { ag -u --hidden --ignore .git -g "" "$@" | xargs dirname | sort | uniq; }
  export FZF_ALT_C_COMMAND="AG_DIRS"
EOF

  # Ctrl+t binding breaks window when tmux + (n)vim + ctrl-z: no visible input. Disable it
  sed -i "s|C-t|C-$|" ~/.fzf/shell/key-bindings.bash
  echo 'source_if_exists ~/.fzf.bash' >> ~/.bashrc
  echo 'source_if_exists ~/.fzf.zsh' >> ~/.zshrc

  mkdir -p ~/project/scripts/custom

  cat >> ~/.shellrc <<"EOF"
  __FZFBookmarkedCommands() {
    cat ~/.bookmarked-commands |
    fzf --height 100% --border -m --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
  }
  __FZFScriptsRaw() {
    find ~/project/scripts -mindepth 2 -type f ! -name "*.md" | grep -v node_modules |
      fzf --height 100% --border -m -q "'" --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
  }
  __FZFScripts() {
    $(__FZFScriptsRaw)
  }
EOF

  cat >> ~/.bashrc <<"EOF"
  bind '"\er": redraw-current-line'
  bind '"\C-q\C-q": "$(__FZFBookmarkedCommands)\e\C-e\er"'
  bind '"\C-q\C-w": "$(__FZFBookmarkedCommands)\e\C-e\er\n"'
  bind '"\C-q\C-a": "$(__FZFScripts)\e\C-e\er"'
  bind '"\C-q\C-s": "$(__FZFScripts)\e\C-e\er\n"'
EOF

cat > ~/.bookmarked-commands <<"EOF"
GitEditorCommit
GitAddAll
GitDiff HEAD -- ':!*package-lock.json' ':!*yarn.lock' | less -r
git fetch
cp .git/COMMIT_EDITMSG /tmp/COMMIT_EDITMSG
(alias ; typeset -f) | NFZF
git commit -m "$(head .git/COMMIT_EDITMSG  -n 1)"
EOF

# https://www.thegeekstuff.com/2011/09/linux-htop-examples
# C: configuration, w: see command wrapped
install_system_package htop
check_file_exists ~/project/provision/htoprc
cat > /tmp/htop_cp_config.sh <<"EOF"
mkdir -p ~/.config/htop
cp ~/project/provision/htoprc ~/.config/htop/htoprc
EOF
sh /tmp/htop_cp_config.sh
cat >> ~/.shell_aliases <<"EOF"
alias HTopDiff='diff ~/project/provision/htoprc ~/.config/htop/htoprc'
alias HTopCPU='htop -s PERCENT_CPU -d 6000'
alias HTopMem='htop -s PERCENT_MEM -d 6000'
EOF

if [ "$PROVISION_OS" == "LINUX" ]; then
  if [ ! -f ~/.dircolors ]; then
    dircolors -p > ~/.dircolors
    COLOR_ITEMS=(FIFO OTHER_WRITABLE STICKY_OTHER_WRITABLE CAPABILITY SETGID SETUID ORPHAN CHR BLK)
    for COLOR_ITEM in "${COLOR_ITEMS[@]}"; do
      sed -i 's|^'"$COLOR_ITEM"' .* #|'"$COLOR_ITEM"' 01;35 #|' ~/.dircolors
    done
  fi

  echo 'eval "$(dircolors ~/.dircolors)"' >> ~/.shellrc
fi

cat > /tmp/tmux_choose_session.sh <<"EOF"
#!/usr/bin/env bash

SESSION=$(tmux ls | grep -o '^.*: ' | sed 's|: ||' | "$HOME"/.fzf/bin/fzf --color light)

if [ -z "$SESSION" ]; then exit 0; fi

tmux switch-client -t "$SESSION"
EOF

echo "bind b split-window 'sh /tmp/tmux_choose_session.sh'" >> ~/.tmux.conf

if [ ! -d ~/project/.git ]; then
  (cd ~/project && git init)
fi

if [ ! -f ~/project/.gitignore ]; then
  cat > ~/project/.gitignore <<"EOF"
/*

!/provision
!.gitignore
!scripts/
!vim-custom-snippets/
EOF
fi

cat >> ~/.shell_aliases <<"EOF"
ProvisionCommitRepo() {
  cd ~/project; git add -A .; git diff HEAD; git status
  read -p "If you are sure, press y: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[y]$ ]]; then
    git commit -m "Update repo"; git push origin master
  fi
  cd -
}
alias ProvisionGetDiff='node $HOME/project/provision/updateProvision.js && sh /tmp/diff_provision.sh'
ProvisionListPossibleConfig() {
  cat ~/project/provision/provision.sh | ag 'project\/\.config\/[-.a-zA-Z0-9]*' -o \
    | sed 's|^|'"$HOME"'|' | sort | uniq > /tmp/config_all;
  mkdir -p ~/project/.config; find ~/project/.config -type f | sort > /tmp/config_used
  echo "# Used" > /tmp/config_printed ; cat /tmp/config_used >> /tmp/config_printed ; printf '\n\n' >> /tmp/config_printed
  echo "# Not used" >> /tmp/config_printed; comm -23 /tmp/config_all /tmp/config_used >> /tmp/config_printed
  less /tmp/config_printed
}
EOF

SOURCE_ASDF='. $HOME/.asdf/asdf.sh'
SOURCE_ASDF_COMPLETION='. $HOME/.asdf/completions/asdf.bash'

echo -e "\n$SOURCE_ASDF" >> ~/.shellrc
echo -e "\n$SOURCE_ASDF_COMPLETION" >> ~/.shellrc

if ! type asdf > /dev/null 2>&1 ; then
  rm -rf ~/.asdf
  # list all versions of language: asdf list all PLUGIN_NAME
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
  eval "$SOURCE_ASDF"
  eval "$SOURCE_ASDF_COMPLETION"
fi

echo 'complete -cf sudo' >> ~/.bashrc

install_system_package task
cat > ~/.taskrc <<"EOF"
# This file is generated from ~/project/provision/provision.sh
# Use the command 'task show' to see all defaults and overrides
data.location=~/.task
alias.d=done
alias.a=add
EOF
if [ "$PROVISION_OS" == "LINUX" ]; then
  echo 'include /usr/share/doc/task/rc/no-color.theme' >> ~/.taskrc
elif [ "$PROVISION_OS" == "MAC" ]; then
  THEME_PATH=$(find /opt/homebrew/Cellar/task -type f -name "no-color.theme")
  echo "include $THEME_PATH" >> ~/.taskrc
fi
echo 'source "$HOME"/.oh-my-zsh/plugins/taskwarrior/taskwarrior.plugin.zsh' >> ~/.zshrc

# only for bash, zsh uses `dirs -v` and `cd -[tab]`
if [ ! -f ~/.acd_func ]; then
  curl -o ~/.acd_func \
    https://raw.githubusercontent.com/djoot/all-bash-history/master/acd_func.sh
fi
echo 'source "$HOME"/.acd_func' >> ~/.bashrc

if [ "$PROVISION_OS" == "LINUX" ]; then
  echo 'LANG=en_US.UTF-8' > /tmp/locale.conf
  sudo mv /tmp/locale.conf /etc/locale.conf

  # to mute/unmute in GUI press M
  install_system_package alsa-utils alsamixer # for audio

  # ufw
  install_system_package ufw
  if [[ ! -z $(sudo ufw status | grep inactive) ]]; then
    sudo ufw --force enable
    sudo systemctl enable --now ufw
  fi
  cat >> ~/.shell_aliases <<"EOF"
alias UFWStatus='sudo ufw status numbered' # numbered is useful for insert / delete
alias UFWLogging='sudo ufw logging on'
UFWDelete() { sudo ufw status numbered ; sudo ufw --force delete $1; sudo ufw status numbered; }
alias UFWBlocked="sudo journalctl | grep -i ufw | tail -f" # For better findings, can use `grep -v -f /tmp/some_file` with some patterns to ignore
UFWAllowOutIPPort() { sudo ufw allow out from any to $1 port $2; }
UFWInit() {
  sudo ufw default deny outgoing; sudo ufw default deny incoming;
  sudo ufw allow out to any port 80; sudo ufw allow out to any port 443;
}
EOF
fi

# GnuPG https://wiki.archlinux.org/title/GnuPG

install_system_package gnupg gpg

cat >> ~/.shell_aliases <<"EOF"
alias GPGCreateKey='gpg --full-gen-key'
alias GPGDecryptSymmetric='gpg --decrypt --no-symkey-cache' # just passphrase
alias GPGDecryptSymmetricSudo='sudo gpg --decrypt --no-symkey-cache --pinentry-mode=loopback' # just passphrase
alias GPGDetachSign='gpg --detach-sign --armor'
alias GPGEditKey='gpg --edit-key' # type `help` for a list of commands
alias GPGEncryptSymmetric='gpg --armor --symmetric --no-symkey-cache' # just passphrase
alias GPGEncryptSymmetricSudo='sudo gpg --pinentry-mode=loopback --armor --symmetric --no-symkey-cache' # just passphrase
alias GPGExportASCIIKey='gpg --export-secret-keys --armor'
alias GPGExportPublic='gpg --export --armor --export-options export-minimal'
alias GPGImportKey='gpg --import' # e.g. GPGImportKey public.key
alias GPGInfo='gpg --version '
alias GPGListKeys='gpg --list-keys'
alias GPGListSecretKeys='gpg --list-secret-keys'
alias GPGReloadAgent='gpg-connect-agent reloadagent /bye'
alias GPGSignature='gpg --clearsign'
alias GPGVerify='gpg --verify'
EOF

cat >> ~/.shell_aliases <<"EOF"
MsgFmtPo() { FILE_NO_EXT="$(echo $1 | sed 's|.po$||')" ; msgfmt -o "$1".mo "$1".po ; }
EOF

if [ ! -f ~/project/.config/inside ]; then
  sudo sed -i -r 's|.?PermitRootLogin.*|PermitRootLogin no|' /etc/ssh/sshd_config
  sudo sed -i -r 's|.?PasswordAuthentication yes|PasswordAuthentication no|' /etc/ssh/sshd_config
  sudo sed -i -r 's|.?PermitEmptyPasswords yes|PermitEmptyPasswords no|' /etc/ssh/sshd_config

  if [ -f ~/.ssh/authorized_keys ]; then sudo chmod 400 ~/.ssh/authorized_keys ; fi
  if [ -f ~/.ssh/config ]; then sudo chmod 400 ~/.ssh/config ; fi

  if [ ! -f /tmp/restarted_sshd ]; then
    echo "Restarting sshd"
    if [ "$PROVISION_OS" == "MAC" ]; then
      sudo launchctl stop com.openssh.sshd
    else
      sudo systemctl restart sshd
    fi
    touch /tmp/restarted_sshd
  fi
else
  rm -rf /tmp/restarted_sshd
fi

# general END

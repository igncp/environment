#!/usr/bin/env bash

set -euo pipefail

. src/general/diagrams.sh
. src/general/fzf.sh
. src/general/git.sh
. src/general/gpg.sh
. src/general/htop.sh
. src/general/mkcert.sh
. src/general/network.sh
. src/general/pi_hole.sh
. src/general/shellcheck.sh
. src/general/taskwarrior.sh
. src/general/tmux.sh

provision_setup_general() {
  mkdir -p $HOME/.scripts/toolbox

  if [ ! -f ~/.ssh/config ]; then
    mkdir -p ~/.ssh
    cp ~/development/environment/src/config-files/ssh-client-config ~/.ssh/config
  fi

  install_system_package "curl"
  install_system_package "git"
  install_system_package "jq"
  install_system_package "lsof"
  install_system_package "rsync"
  install_system_package "tree"
  install_system_package "wget"

  if [ "$IS_NIXOS" != "1" ]; then
    install_system_package "base-devel" "make"
  fi

  cat >>~/.shellrc <<"EOF"
export EDITOR=vim
umask 077
EOF

  if [ ! -f ~/.git-prompt ]; then
    if type pacman >/dev/null 2>&1; then
      sudo pacman -S --noconfirm bash-completion
    fi
    curl -k -o ~/.git-prompt https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
  fi

  cat >~/.shell_sources <<"EOF"
source_if_exists() {
  FILE_PATH=$1
  if [ -f $FILE_PATH ]; then source $FILE_PATH; fi
}

source_if_exists ~/.shell_aliases
source_if_exists ~/.git-prompt
EOF

  cat ~/development/environment/src/config-files/.shell_aliases.sh >>~/.shell_aliases

  if [ "$IS_LINUX" == "1" ]; then
    if type dircolors >/dev/null 2>&1; then
      if [ ! -d ~/.dircolors ]; then
        dircolors -p >~/.dircolors
        COLOR_ITEMS=(FIFO OTHER_WRITABLE STICKY_OTHER_WRITABLE CAPABILITY SETGID SETUID ORPHAN CHR BLK)
        for COLOR_ITEM in "${COLOR_ITEMS[@]}"; do
          sed -i 's|^'"$COLOR_ITEM"' .* #|'"$COLOR_ITEM"' 01;35 #|' ~/.dircolors
        done
      fi

      echo 'eval "$(dircolors ~/.dircolors)"' >>~/.shellrc
    fi
  fi

  if [ ! -f "$PROVISION_CONFIG"/ssh-notice-color ]; then
    echo 'cyan' >"$PROVISION_CONFIG"/ssh-notice-color
  fi

  cat >>~/.shell_aliases <<"EOF"
MsgFmtPo() { FILE_NO_EXT="$(echo $1 | sed 's|.po$||')" ; msgfmt -o "$1".mo "$1".po ; }
EOF

  # @TODO
  #     // Only for bash, zsh uses `dirs -v` and `cd -[tab]`
  #     if !Path::new(&context.system.get_home_path(".acd_func")).exists() {
  #         System::run_bash_command(
  #             r###"
  # curl -k -o ~/.acd_func \
  #     https://raw.githubusercontent.com/djoot/all-bash-history/master/acd_func.sh
  # "###,
  #         );
  #         context.files.appendln(
  #             &context.system.get_home_path(".bashrc"),
  #             r#"source "$HOME"/.acd_func"#,
  #         );
  #     }

  #     context.files.append(
  #         &context.system.get_home_path(".bash_profile"),
  #         r###"
  # if [ -f "$HOME/.bashrc" ]; then
  #   . "$HOME/.bashrc"
  # fi
  # "###,
  #     );

  cat >>~/.bashrc <<"EOF"
export GTK_IM_MODULE="ibus";
export QT_IM_MODULE="ibus";
export XMODIFIERS="@im=ibus";

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
source ~/.shell_aliases
source ~/.shell_sources

. ~/development/environment/src/scripts/misc/ps1.sh

PS1='$(provision_get_ps1 "$(jobs)")'
EOF

  cat >~/.inputrc <<"EOF"
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

  # @TODO
  #     if context.system.is_linux() && !context.system.is_nixos() {
  #         System::run_bash_command(
  #             r###"
  # echo 'LANG=en_US.UTF-8' > /tmp/locale.conf
  # sudo mv /tmp/locale.conf /etc/locale.conf

  # if [[ ! -z $(sudo ufw status | grep inactive) ]]; then
  #     sudo ufw allow ssh
  #     sudo ufw --force enable
  #     sudo systemctl enable --now ufw
  # fi
  # "###,
  #         );

  #         context.files.append(
  #             &context.system.get_home_path(".shell_aliases"),
  #             r###"
  # alias UFWStatus='sudo ufw status numbered' # numbered is useful for insert / delete
  # alias UFWLogging='sudo ufw logging on'
  # UFWDelete() { sudo ufw status numbered ; sudo ufw --force delete $1; sudo ufw status numbered; }
  # alias UFWBlocked="sudo journalctl | grep -i ufw | tail -f" # For better findings, can use `grep -v -f /tmp/some_file` with some patterns to ignore
  # UFWAllowOutIPPort() { sudo ufw allow out from any to $1 port $2; }
  # UFWInit() {
  #     sudo ufw default deny outgoing; sudo ufw default deny incoming;
  #     sudo ufw allow out to any port 80; sudo ufw allow out to any port 443;
  # }
  # "###,
  #         );
  #     }

  #     context
  #         .system
  #         .install_system_package("net-tools", Some("netstat"));

  #     context.files.appendln(
  #         &context.system.get_home_path(".bashrc"),
  #         "complete -cf sudo",
  #     );

  cat >>~/.shellrc <<"EOF"
export PATH="$PATH:$HOME/development/environment/src/scripts"
export PATH="$PATH:$HOME/development/environment/src/scripts/bootstrap"
export PATH="$PATH:$HOME/.local/bin"
EOF

  cat >>~/.shell_aliases <<"EOF"
alias ShellFormat='shfmt -i 2 -w'

# https://stackoverflow.com/a/22625150
CurlMeasureTime() {
  cat > /tmp/curl_measure_time.txt <<"EOF2"
  time_namelookup:  %{time_namelookup}s\n
        time_connect:  %{time_connect}s\n
     time_appconnect:  %{time_appconnect}s\n
    time_pretransfer:  %{time_pretransfer}s\n
       time_redirect:  %{time_redirect}s\n
  time_starttransfer:  %{time_starttransfer}s\n
                     ----------\n
          time_total:  %{time_total}s\n
EOF2
  curl -w "@/tmp/curl_measure_time.txt" -o /dev/null -s $@
}
EOF

  if [ -f "$PROVISION_CONFIG"/stripe ]; then
    echo 'export STRIPE_CLI_TELEMETRY_OPTOUT=1' >>~/.shellrc
  fi

  # https://lzone.de/cheat-sheet/etcd
  echo 'export ETCDCTL_API=3' >>~/.shellrc

  if [ -f "$PROVISION_CONFIG"/ssh_agent_shared ]; then
    if [ "$IS_MAC" == "1" ]; then
      cat >>~/.shellrc <<"EOF"
export SSH_AUTH_SOCK="$(find /tmp/com.apple.launchd.*/Listeners -type s)"
EOF
    else
      cat >>~/.shellrc <<"EOF"
SSH_ENV="$HOME/.ssh-agent-environment"

function start_agent {
  printf "Initialising a new SSH agent... "
  ssh-agent | sed 's/^echo/#echo/' >"$SSH_ENV"
  printf "succeeded\n"
  chmod 600 "$SSH_ENV"
  . "$SSH_ENV" >/dev/null
  ssh-add
}

if [ -f "$SSH_ENV" ]; then
  . "$SSH_ENV" >/dev/null
  ps -ef | grep $SSH_AGENT_PID | grep 'ssh-agent$' >/dev/null && echo "Connecting to the SSH agent" || {
    start_agent
  }
else
  start_agent
fi
EOF
    fi
  fi

  # macOS 特定版本: `wget https://release.files.ghostty.org/1.0.1/Ghostty.dmg`
  if type ghostty >/dev/null 2>&1; then
    mkdir -p ~/.config/ghostty
    cp ~/development/environment/src/config-files/ghostty ~/.config/ghostty/config

    if [ -f ~/Library/Application\ Support/com.mitchellh.ghostty/config ]; then
      cp ~/development/environment/src/config-files/ghostty ~/Library/Application\ Support/com.mitchellh.ghostty/config
    fi
  fi

  if type newsboat >/dev/null 2>&1; then
    mkdir -p ~/.newsboat
    cp src/config-files/newsboat-config $HOME/.newsboat/config
  fi

  if type cmus >/dev/null 2>&1; then
    mkdir -p ~/.config/cmus
    cp src/config-files/cmus-theme ~/.config/cmus/custom.theme
  fi

  if type fastfetch >/dev/null 2>&1; then
    mkdir -p ~/.config/fastfetch
    cp src/config-files/fastfetch.jsonc ~/.config/fastfetch/config.jsonc
  fi

  provision_setup_general_diagrams
  provision_setup_general_fzf
  provision_setup_general_git
  provision_setup_general_gpg
  provision_setup_general_htop
  provision_setup_general_mkcert
  provision_setup_general_network
  provision_setup_general_pi_hole
  provision_setup_general_shellcheck
  provision_setup_general_taskwarrior
  provision_setup_general_tmux
}

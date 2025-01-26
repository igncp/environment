#!/usr/bin/env bash

set -e

install_windows_package() {
  if [ ! -d "$APPDATA/Microsoft/Windows/Start Menu/Programs/$2" ] &&
    [ ! -d "/c/ProgramData/Microsoft/Windows/Start Menu/Programs/$2" ]; then

    if type "$2" >/dev/null; then
      return
    fi

    echo "安裝 $1"
    winget install $1
  fi

}

provision_setup_os_windows() {
  cat >~/.bash_profile <<"EOF"
. ~/.shellrc
. ~/.shell_aliases

cd ~/development/environment

alias l="less -i"
alias rm='rm -rf'
alias e='explorer.exe'
alias ag="ag --hidden  --color-match 7"
alias agg='ag --hidden --ignore node_modules --ignore .git'
alias cp="cp -r"
alias ll="ls -lah --color=always"
alias mkdir="mkdir -p"
alias tree="tree -a"

nf() {
  FILE="$(find ${1:-.} | fzf)"
  if [ -n "$FILE" ]; then
    nvim "$FILE"
  fi
}
alias n='nvim'

alias ExplorerStartup='(cd $APPDATA/Microsoft/Windows/Start\ Menu/Programs/Startup/ && explorer.exe .)'
alias ExplorerEnvironment='(cd $USERPROFILE/development/environment && explorer.exe .)'
alias Provision="(cd ~/development/environment && bash src/windows.sh)"
alias HostsEdit='sudo vim /c/Windows/System32/Drivers/etc/hosts'

if [ -f ~/.fzf.key-bindings.bash ]; then
    source ~/.fzf.key-bindings.bash
else
    echo "~/.fzf.key-bindings.bash 文件遺失 (此訊息來自 ~/.bash_profile)"
fi

export PROMPT_COMMAND='history -a'
EOF

  cat >~/.inputrc <<"EOF"
set bell-style none
EOF

  if [ ! -f ~/.check-files/windows ]; then
    install_windows_package "RARLab.WinRAR" "WinRAR" || true
    install_windows_package "AutoHotkey.AutoHotkey" "AutoHotkey.lnk" || true
    install_windows_package "tailscale.tailscale" "Tailscale.lnk" || true
    install_windows_package "AgileBits.1Password" "1Password.lnk" || true

    install_windows_package "JFLarvoire.Ag" "ag.exe"
    install_windows_package "junegunn.fzf" "fzf.exe"
    install_windows_package "gerardog.gsudo" "gsudo.exe"

    if ! type "jq" >/dev/null; then
      echo "以管理員身份執行以下命令進行安裝 jq:"
      echo curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
    fi

    touch ~/.check-files/windows
  fi

  provision_setup_general_git
  provision_setup_general_fzf
  provision_setup_nvim_vim

  echo 'syntax on' >>~/.vimrc
  mkdir -p ~/AppData/Local/nvim
  cp ~/.vimrc ~/AppData/Local/nvim/init.vim

  echo "腳本成功完成"
}

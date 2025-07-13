#!/usr/bin/env bash

set -euo pipefail

provision_setup_general_taskwarrior() {
  if [ ! -f "$PROVISION_CONFIG"/taskwarrior ]; then
    return
  fi

  install_system_package taskwarrior task

  cat >~/.taskrc <<"EOF"
# This file is generated from ~/development/environment
# Use the command 'task show' to see all defaults and overrides
data.location=~/.task
alias.d=done
alias.a=add
EOF

  if [ "$IS_LINUX" == "1" ]; then
    if [ -f /usr/share/taskwarrior/no-color.theme ]; then
      echo "include /usr/share/taskwarrior/no-color.theme" >>~/.taskrc
    elif [ -f /usr/share/doc/task/rc/no-color.theme ]; then
      echo "include /usr/share/doc/task/rc/no-color.theme" >>~/.taskrc
    fi
  elif [ "$IS_MAC" == "1" ]; then
    if [ -f /opt/homebrew/Cellar/task ]; then
      echo "include /opt/homebrew/Cellar/task/3.6.0_1/share/doc/task/no-color.theme" >>~/.taskrc
      THEME_PATH="$(find /opt/homebrew/Cellar/task -type f -name 'no-color.theme')"
      echo "include $THEME_PATH" >>~/.taskrc
    fi
  fi

  cat >>~/.zshrc <<"EOF"
source "$HOME"/.oh-my-zsh/plugins/taskwarrior/taskwarrior.plugin.zsh
EOF
}

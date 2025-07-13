#!/usr/bin/env bash

set -euo pipefail

provision_setup_homebrew() {
  if [ ! -f "$PROVISION_CONFIG"/homebrew ]; then
    if [ ! -f "$PROVISION_CONFIG"/minimal ]; then
      return
    fi
  fi

  if ! type "brew" >/dev/null 2>&1; then
    if [ ! -d "$HOME"/homebrew ]; then
      cd ~
      mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
    fi
    export PATH="$HOME/hombrew/bin:$PATH"
  fi

  # 在 MacOS 中，這需要在「Terminal」應用程式中運行
  if [ ! -f ~/.check-files/coreutils ]; then
    brew install coreutils
    brew install diffutils # for diff
    brew install \
      gnu-sed sponge neovim tmux ripgrep fzf git git-summary \
      neovim-remote tree wget ag shfmt jq yq bash awscli eksctl

    touch ~/.check-files/coreutils
  fi

  export PATH="$HOME/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

  cat >>~/.shell_aliases <<"EOF"
alias BrewListPackages='brew list'
alias BrewUpgrade='brew outdated | xargs brew install'
EOF

  cat >/tmp/hombrew_load <<"EOF"
if [ -d "$HOME"/homebrew/bin ]; then
  export PATH="$HOME/homebrew/bin:$PATH"
fi

if [ -d "$HOME"/homebrew/opt/gnu-sed/libexec/gnubin ]; then
  export PATH="$HOME/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi

if [ -d "$HOME/homebrew/opt/openjdk@11/bin" ]; then
  export PATH="$HOME/homebrew/opt/openjdk@11/bin:$PATH"
fi

if [ -d "$HOME/homebrew/opt/openjdk@17/bin" ]; then
  export PATH="$HOME/homebrew/opt/openjdk@17/bin:$PATH"
fi
EOF
  cat /tmp/hombrew_load >/tmp/hombrew_load_file
  cat ~/.bashrc >>/tmp/hombrew_load_file && mv /tmp/hombrew_load_file ~/.bashrc
  cat /tmp/hombrew_load >/tmp/hombrew_load_file
  cat ~/.zshrc >>/tmp/hombrew_load_file && mv /tmp/hombrew_load_file ~/.zshrc
  rm /tmp/hombrew_load
}

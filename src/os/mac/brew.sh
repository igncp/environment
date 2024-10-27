#!/usr/bin/env bash

set -e

provision_setup_os_mac_brew() {
  if [ ! -f "$PROVISION_CONFIG"/mac_brew ]; then
    return
  fi

  cat >>~/.shellrc <<"EOF"
eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
EOF

  if ! type "brew" >/dev/null 2>&1; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [ ! -f ~/.check-files/coreutils ]; then
    brew install coreutils
    brew install diffutils # for diff
    brew install iterm2 || true

    touch ~/.check-files/coreutils
  fi

  if ! type aerospace >/dev/null 2>&1; then
    # https://github.com/nikitabobko/homebrew-tap/tree/main/Casks
    brew install --cask nikitabobko/tap/aerospace@0.13.4
  fi

  if ! type pinentry-tty >/dev/null 2>&1; then
    # Using `brew` because didn't find it in `nixpkgs`
    brew install pinentry
  fi
  mkdir -p ~/.gnupg
  echo "pinentry-program /opt/homebrew/bin/pinentry-tty" >~/.gnupg/gpg-agent.conf

}

#!/usr/bin/env bash

set -e

provision_setup_os_mac() {
  # Rime - Squirrel
  #   I can't remember the location, but it may be from:
  #     https://github.com/rime/squirrel/releases
  #     https://github.com/rime/squirrel/issues/471#issuecomment-748751617
  #   Use `~/Library/Rime/default.custom.yaml``
  #   The `patch` in the top level, above `schemas`, is necessary

  mkdir -p ~/Library/KeyBindings

  cat >>~/.shellrc <<"EOF"
umask 027

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
EOF

  cat >~/Library/KeyBindings/DefaultKeyBinding.dict <<EOF
{
  /* Map # to § key*/
  "§" = ("insertText:", "#");
}
EOF

  if ! type "brew" >/dev/null 2>&1; then
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [ ! -f ~/.check-files/coreutils ]; then
    brew install coreutils
    brew install diffutils # for diff

    touch ~/.check-files/coreutils
  fi

  cat >>~/.shell_aliases <<"EOF"
alias MacDisks='diskutil list'
alias MacFeatures='system_profiler > /tmp/features.txt && echo "/tmp/features.txt written" && less /tmp/features.txt'
alias BrewListPackages='brew list'

# Edit this file: `/etc/pf.conf`
# For example: `pass in proto tcp from any to any port 3000`
alias MacRestartFirewallConfig='sudo pfctl -f /etc/pf.conf'
EOF

  if [ ! -f ~/.check-files/init-apps ]; then
    brew install iterm2 || true
    brew install mysqlworkbench || true

    # Reduce transparency
    defaults write com.apple.universalaccess reduceTransparency -bool true || true

    # Safari debug
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true &&
      defaults write com.apple.Safari IncludeDevelopMenu -bool true &&
      defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true &&
      defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true &&
      defaults write -g WebKitDeveloperExtras -bool true || true

    # Keep the screen on after disconnecting the screen sharing client
    sudo defaults write /Library/Preferences/com.apple.RemoteManagement RestoreMachineState -bool NO

    # Xcode command-line tools
    xcode-select --install || true

    # Disable automatic arrangement of spaces
    defaults write com.apple.dock mru-spaces -bool false && killall Dock
    # Autohide dock
    defaults write com.apple.dock autohide -bool true && killall Dock
    # Disable icon bounce on notification
    defaults write com.apple.dock no-bouncing -bool false && killall Dock
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles true
    # Show hidden dir
    chflags nohidden ~/Library
    # Hide desktop icons
    defaults write com.apple.finder CreateDesktop -bool false && killall Finder
    # Show pathbar at the bottom
    defaults write com.apple.finder ShowPathbar -bool true

    cat >>~/.shell_aliases <<"EOF"
alias MacListAppsAppStore='mdfind kMDItemAppStoreHasReceipt=1'
alias MacEjectAll="osascript -e 'tell application "'"Finder"'" to eject (every disk whose ejectable is true)'"
EOF

    touch ~/.check-files/init-apps
  fi

  if ! type pinentry-tty >/dev/null 2>&1; then
    # Using `brew` because didn't find it in `nixpkgs`
    brew install pinentry
  fi
  mkdir -p ~/.gnupg
  echo "pinentry-program /opt/homebrew/bin/pinentry-tty" >~/.gnupg/gpg-agent.conf

  echo 'set backspace=indent,eol,start' >>~/.vimrc
}

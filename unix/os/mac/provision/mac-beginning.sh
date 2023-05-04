# mac-beginning START

install_system_package() {
  PACKAGE="$1"
  if [[ ! -z "$2" ]]; then CMD_CHECK="$2"; else CMD_CHECK="$1"; fi
  if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
    echo "doing: brew install $PACKAGE"
    brew install "$PACKAGE"
  fi
}

mkdir -p ~/Library/KeyBindings/
cat > ~/Library/KeyBindings/DefaultKeyBinding.dict <<"EOF"
{
  /* Map # to § key*/
  "§" = ("insertText:", "#");
}
EOF

if ! type brew > /dev/null 2>&1 ; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ ! -f ~/.check-files/coreutils ]; then
  brew install coreutils
  brew install gnu-sed # sed with same options as in linux
  brew install diffutils # for diff
  touch ~/.check-files/coreutils
fi

cat >> ~/.shellrc <<"EOF"
umask 027

eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
EOF

cat >> ~/.shell_aliases <<"EOF"
alias MacDisks='diskutil list'
alias MacFeatures='system_profiler > /tmp/features.txt && echo "/tmp/features.txt written" && less /tmp/features.txt'
alias BrewListPackages='brew list'

# Edit this file: `/etc/pf.conf`
# For example: `pass in proto tcp from any to any port 3000`
alias MacRestartFirewallConfig='sudo pfctl -f /etc/pf.conf'
EOF

cat >> ~/.zshrc <<"EOF"
# For chinese characters
export LANG="en_US.UTF-8"
export LC_ALL=en_US.utf-8
EOF

install_system_package pinentry pinentry-tty

mkdir -p ~/.gnupg
cat > ~/.gnupg/gpg-agent.conf <<"EOF"
pinentry-program /opt/homebrew/bin/pinentry-tty
EOF

if [ ! -f ~/.check-files/init-apps ]; then
  brew install iterm2 || true
  brew install mysqlworkbench || true

  # Reduce transparency
  defaults write com.apple.universalaccess reduceTransparency -bool true || true

  # Safari debug
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true && \
  defaults write com.apple.Safari IncludeDevelopMenu -bool true && \
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true && \
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true && \
  defaults write -g WebKitDeveloperExtras -bool true || true

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

  cat >> ~/.shell_aliases <<"EOF"
alias MacListAppsAppStore='mdfind kMDItemAppStoreHasReceipt=1'
alias MacEjectAll="osascript -e 'tell application "'"Finder"'" to eject (every disk whose ejectable is true)'"
EOF

  touch ~/.check-files/init-apps
fi

# Rime - Squirrel
  # I can't remember the location, but it may be from:
    # https://github.com/rime/squirrel/releases
  # https://github.com/rime/squirrel/issues/471#issuecomment-748751617
    # Use `~/Library/Rime/default.custom.yaml``
    # The `patch` in the top level, above `schemas`, is necessary

# Switch tilde with the top left key in the keyboard
# As an improvement it could be added to `launchctl`
# TODO: This doesn't work well with external keyboards
# cat << 'EOF' > ~/.scripts/tilde-switch.sh && chmod +x ~/.scripts/tilde-switch.sh
# hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064},{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035}]}'
# EOF
# cat >> ~/.shellrc <<"EOF"
# sh ~/.scripts/tilde-switch.sh 2>&1 > /dev/null
# EOF

if [ -f ~/project/.config/network-analysis ]; then
  if ! type wireshark > /dev/null 2>&1 ; then
    brew install --cask wireshark
  fi
  install_system_package mitmproxy
fi

# mac-beginning END

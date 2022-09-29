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
  brew install iterm2
  brew install mysqlworkbench
  touch ~/.check-files/init-apps
fi

# Switch tilde with the top left key in the keyboard
# As an improvement it could be added to `launchctl`
cat << 'EOF' > ~/.scripts/tilde-switch.sh && chmod +x ~/.scripts/tilde-switch.sh
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000035,"HIDKeyboardModifierMappingDst":0x700000064},{"HIDKeyboardModifierMappingSrc":0x700000064,"HIDKeyboardModifierMappingDst":0x700000035}]}'
EOF
cat >> ~/.shellrc <<"EOF"
sh ~/.scripts/tilde-switch.sh 2>&1 > /dev/null
EOF

# mac-beginning END

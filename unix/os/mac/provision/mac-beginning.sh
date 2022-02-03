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
  mkdir -p ~/.check-files && touch ~/.check-files/coreutils
fi

cat >> ~/.shellrc <<"EOF"
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

# mac-beginning END

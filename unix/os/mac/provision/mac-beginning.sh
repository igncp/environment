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
  mkdir -p ~/.check-files && touch ~/.check-files/coreutils
fi

# mac-beginning END

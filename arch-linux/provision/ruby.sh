# ruby START

if ! type ruby > /dev/null 2>&1 ; then
  asdf plugin add ruby

  # depends on libssl-dev
  asdf install ruby 2.7.0

  asdf global ruby 2.7.0
fi

install_gems() {
  GEMS_LIST=$(gem list)
  for GEM_NAME in "$@"; do
    if [ $(echo "$GEMS_LIST" | grep -c "^$GEM_NAME ") -eq "0" ]; then
      echo "doing: gem install $GEM_NAME"
      gem install "$GEM_NAME"
    fi
  done
}

install_gems bundler lolcat fit-commit

# ruby END

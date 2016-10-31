# ruby START

RUBY_VERSION=2.2.4
if [ ! -f ~/.ruby-installation-finished ]; then
  sudo apt-get purge -y ruby ruby1.9
  sudo apt-get autoremove -y
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | bash -s stable
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  ~/.rvm/bin/rvm install "$RUBY_VERSION"
  ~/.rvm/bin/rvm use --default "$RUBY_VERSION"
  touch ~/.ruby-installation-finished
fi

cat >> ~/.bashrc <<"EOF"

export PATH="$PATH:~/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
EOF

install_gems() {
  GEMS_LIST=$(~/.rvm/gems/ruby-"$RUBY_VERSION"/wrappers/gem list)
  for GEM_NAME in "$@"; do
    if [ $(echo "$GEMS_LIST" | grep "^$GEM_NAME " | wc -l) -eq "0" ]; then
      echo "doing: gem install $GEM_NAME --no-ri --no-rdoc"
      ~/.rvm/gems/ruby-"$RUBY_VERSION"/wrappers/gem install "$GEM_NAME" --no-ri --no-rdoc
    fi
  done
}

install_gems bundler

# ruby END

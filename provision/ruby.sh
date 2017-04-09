# ruby START

RUBY_VERSION=2.2.4
if [ ! -d ~/.rbenv ]; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  cd ~/.rbenv && src/configure && make -C src
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  ~/.rbenv/bin/rbenv install "$RUBY_VERSION"
  ~/.rbenv/bin/rbenv init - > ~/.rbenv-init
  eval "$(~/.rbenv/bin/rbenv init -)"
  ~/.rbenv/bin/rbenv global "$RUBY_VERSION"
fi

echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'source_if_exists ~/.rbenv-init' >> ~/.bash_sources

install_gems() {
  GEMS_LIST=$(~/.rbenv/shims/gem list)
  for GEM_NAME in "$@"; do
    if [ $(echo "$GEMS_LIST" | grep -c "^$GEM_NAME ") -eq "0" ]; then
      echo "doing: gem install $GEM_NAME --no-ri --no-rdoc"
      ~/.rbenv/shims/gem install "$GEM_NAME" --no-ri --no-rdoc
    fi
  done
}

install_gems bundler lolcat fit-commit

# ruby END

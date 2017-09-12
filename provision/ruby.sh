# ruby START

install_pacman_package ruby

echo $'export PATH="$(ruby -e \'print Gem.user_dir\')/bin:$PATH"' >> ~/.bashrc

install_gems() {
  GEMS_LIST=$(gem list)
  for GEM_NAME in "$@"; do
    if [ $(echo "$GEMS_LIST" | grep -c "^$GEM_NAME ") -eq "0" ]; then
      echo "doing: gem install $GEM_NAME --no-ri --no-rdoc"
      gem install "$GEM_NAME" --no-ri --no-rdoc
    fi
  done
}

install_gems bundler lolcat fit-commit

# ruby END

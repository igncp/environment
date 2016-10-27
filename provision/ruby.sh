# ruby START

GEM_NAMES=(bundler)

GEMS_LIST=$(gem list)
for GEM_NAME in "${GEM_NAMES[@]}"; do
  if [ $(echo "$GEMS_LIST" | grep "$GEM_NAME " | wc -l) -eq "0" ]; then
    echo "doing: sudo gem install $GEM_NAME --no-ri --no-rdoc"
    sudo gem install "$GEM_NAME" --no-ri --no-rdoc
  fi
done

# ruby END

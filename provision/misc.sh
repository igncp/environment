# misc START

if [ ! -d ~/english-words ]; then
  git clone https://github.com/dwyl/english-words ~/english-words
fi


clone_example_from_gh() {
  PARENT_PATH=~/examples/$1
  REPO_URL=https://github.com/$2.git
  DIR=$(echo $2 | sed -r "s|(.+)/(.+)|\1_-_\2|") # foo/bar => foo_-_bar
  COMMIT=$3
  FULL_PATH=$PARENT_PATH/$DIR
  mkdir -p $PARENT_PATH
  if [ ! -d $FULL_PATH ]; then
    git clone $REPO_URL $FULL_PATH
    cd $FULL_PATH
    git reset --hard $COMMIT > /dev/null 2>&1
    cd - > /dev/null 2>&1
  fi
}

# github issues
  if ! type ghi > /dev/null 2>&1; then
    curl -sL https://raw.githubusercontent.com/stephencelis/ghi/master/ghi > ghi && \
      chmod 755 ghi && \
      sudo mv ghi /usr/local/bin
  fi

# misc END

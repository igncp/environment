#!/usr/bin/env bash

DIR_PATH=$(find . -type d ! -path "*.git*" ! -path "*node_modules*" | \
  fzf --height 100% --border -m  --ansi)

if [ -z "$DIR_PATH" ]; then
  exit 0;
fi

NAME=$(echo "" | fzf --header 'Please enter the name' --print-query)

if [ -z "$NAME" ]; then
  exit 0;
fi

cat > /tmp/compress-command <<"EOF"
zip
tar
EOF

COMMAND=$(fzf -m --header 'Choose the way to compress' < /tmp/compress-command)
CURRENT_DIR=$(pwd)

cd $DIR_PATH
DIR_NAME=${PWD##*/}
cd $CURRENT_DIR
GENERATED_FILE_PATH=$(realpath "$DIR_PATH/../$NAME")

echo_if_not_file() {
  EXT="$1"
  CMD="$2"
  if [ -f "$GENERATED_FILE_PATH.$EXT" ]; then
    echo "echo 'stopping because the file $GENERATED_FILE_PATH.$EXT would be overriden'"
  else
    echo "$CMD"
  fi
}

if [ "$COMMAND" == "zip" ]; then
  echo_if_not_file "zip" "(cd $DIR_PATH/..; zip -r $NAME.zip $DIR_NAME; mv $NAME.zip $CURRENT_DIR; cd $CURRENT_DIR)"
elif [ "$COMMAND" == "tar" ]; then
  echo_if_not_file "tar.gz" "(cd $DIR_PATH/..; tar -zcvf $NAME.tar.gz $DIR_NAME; mv $NAME.tar.gz $CURRENT_DIR; cd $CURRENT_DIR)"
fi

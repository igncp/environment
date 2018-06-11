#!/usr/bin/env bash

FILE=$(find . -type f -name "*.zip" -o -name "*.tar.gz" ! -path "*.git*" ! -path "*node_modules*" | \
  fzf --height 100% --border -m  --ansi)

if [ -z "$FILE" ]; then
  exit 0;
fi

WHERE=$(find . -type d ! -path "*.git*" ! -path "*node_modules*" | \
  fzf --height 100% --border -m  --ansi --header 'Please choose the directory where to uncompress the file')

if [ -z "$WHERE" ]; then
  exit 0;
fi

if [ "${FILE: -4}" == ".zip" ]; then
  echo "unzip $FILE -d $WHERE"
elif [ "${FILE: -7}" == ".tar.gz" ]; then
  echo "tar xvzf $FILE -C $WHERE"
fi

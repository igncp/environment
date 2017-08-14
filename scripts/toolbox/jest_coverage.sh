#!/usr/bin/env bash

TEST_FILE=$(find . -type f ! -path "*node_modules*" ! -path "*.git*" -name "*.test.*"| \
  fzf --height 100% --border  --ansi --header "Please hoose the test file")

if [ -z "$TEST_FILE" ]; then
  exit 0
fi

SRC_FILE=$(find . -type f ! -path "*node_modules*" ! -path "*.git*" ! -name "*.test.*" | \
  fzf --height 100% --border  --ansi --header "Please hoose the source file" | sed "s|^./||")

if [ -z "$SRC_FILE" ]; then
  exit 0
fi

echo './node_modules/.bin/jest "'"$TEST_FILE"'" --watch --coverage --collectCoverageFrom="'"$SRC_FILE"'"'

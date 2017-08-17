#!/usr/bin/env bash

SRC_FILE=$(find . -type f ! -path "*node_modules*" ! -path "*.git*" ! -name "*.test.*" ! -path "*coverage*" |
  fzf --height 100% --border --ansi --header "Please choose the source file to check the coverage" |
  sed "s|^./||")

if [ -z "$SRC_FILE" ]; then
  exit 0
fi

TEST_FILE=$(find . -type f ! -path "*node_modules*" ! -path "*.git*" -name "*.test.*" |
  fzf --height 100% --border --ansi --header "Please choose the test file")

if [ -z "$TEST_FILE" ]; then
  exit 0
fi

SECONDARY_TEST_FILE=$(find . -type f ! -path "*node_modules*" ! -path "*.git*" -name "*.test.*" |
  fzf --height 100% --border --ansi --header "Please choose a secondary test file to make the output shorter (optional)")

if [ -z "$SECONDARY_TEST_FILE" ]; then
  SECONDARY_WITH_QUOTES=""
else
  SECONDARY_WITH_QUOTES='"'"$SECONDARY_TEST_FILE"'"'
fi

echo './node_modules/.bin/jest --watch --coverage --collectCoverageFrom="'"$SRC_FILE"'" '"$SECONDARY_WITH_QUOTES"' "'"$TEST_FILE"'"'

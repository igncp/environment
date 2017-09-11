#!/usr/bin/env bash

FIND_CMD='find . -type f ! -path "*node_modules*" ! -path "*.git*" ! -path "*coverage*" ! -path "*.happypack*"'

SRC_FILE=$(eval "$FIND_CMD ! -name '*.test.*'" |
  fzf --height 100% --border --ansi --header "Please choose the source file to check the coverage" |
  sed "s|^./||")

if [ -z "$SRC_FILE" ]; then
  exit 0
fi

SRC_FILE_NAME=$(basename "$SRC_FILE" | cut -d'.' -f1)

TEST_FILE=$(eval "$FIND_CMD -name '*.test.*'" |
  fzf --height 100% --border --query "$SRC_FILE_NAME" --ansi --header "Please choose the test file")

if [ -z "$TEST_FILE" ]; then
  exit 0
fi

CACHED_FILE_PATH_FOR_SECONDARY_TEST_FILE="/tmp/$(pwd | sed 's|^.||g; s|/|-|g')-jest-coverage"

if [ -f "$CACHED_FILE_PATH_FOR_SECONDARY_TEST_FILE" ]; then
  CACHED_FILE_CONTENT_FOR_SECONDARY_TEST_FILE=$(cat "$CACHED_FILE_PATH_FOR_SECONDARY_TEST_FILE")
fi

SECONDARY_TEST_FILE=$(eval "$FIND_CMD -name '*.test.*'" |
  fzf --height 100% --border --ansi --query "$CACHED_FILE_CONTENT_FOR_SECONDARY_TEST_FILE" \
    --header "Please choose a secondary test file to make the output shorter (optional)")

if [ -z "$SECONDARY_TEST_FILE" ]; then
  SECONDARY_WITH_QUOTES=""
else
  echo "$SECONDARY_TEST_FILE" > "$CACHED_FILE_PATH_FOR_SECONDARY_TEST_FILE"
  SECONDARY_WITH_QUOTES='"'"$SECONDARY_TEST_FILE"'"'
fi

echo './node_modules/.bin/jest --watch --coverage --collectCoverageFrom="'"$SRC_FILE"'" '"$SECONDARY_WITH_QUOTES"' "'"$TEST_FILE"'"'

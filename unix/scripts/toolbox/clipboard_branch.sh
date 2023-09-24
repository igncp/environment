#!/usr/bin/env bash

CURRENT_BRANCH_CMD='printf $(git rev-parse --abbrev-ref HEAD) | '

if [ -f ~/development/environment/project/.config/clipboard-ssh ]; then
  echo "$CURRENT_BRANCH_CMD ~/.scripts/cargo_target/release/clipboard_ssh send"
  exit 0
elif type "pbcopy" >/dev/null; then
  echo "$CURRENT_BRANCH_CMD pbcopy"
  exit 0
elif type "xclip" >/dev/null; then
  echo "$CURRENT_BRANCH_CMD xclip -selection clipboard"
  exit 0
fi

echo 'echo No clipboard utility found.'

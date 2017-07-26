#!/usr/bin/env bash

sudo updatedb &

CMD=$(echo "" | fzf --print-query --header "Please enter the command")

if [ -z "$CMD" ]; then
  exit 0
fi

PARTS=$(echo "" | fzf --print-query --header 'Please enter parts for locate' -q "$(pwd)")

SELECTED_PATH=$(locate -A "$PARTS" | fzf)

if [ -z "$SELECTED_PATH" ]; then
  exit 0
fi

echo "$CMD $SELECTED_PATH"

#!/usr/bin/env bash

SESSION=$(tmux list-sessions | sort |
  fzf --height 100% --border -m --ansi --multi --tac \
  | sed "s|:.*$||")

if [ -z "$SESSION" ]; then
  exit 0
fi

CMD="tmux kill-session -t $SESSION"

echo "$CMD"

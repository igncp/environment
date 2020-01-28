#!/usr/bin/env bash

sudo pkill -f tmux

tmux \
  new-session -s SESSION_NAME \; \
  send-keys 'cd ~/PATH/TO/FILE; clear' C-m \; \
\
  new-window \; \
  send-keys "echo foo" C-m \; \
\
  kill-session -t 0  \; \
  select-window -t 0 \;

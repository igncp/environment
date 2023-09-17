#!/usr/bin/env bash

sudo pkill -f tmux

cat >> /tmp/tmux_bootstrap_bindings.txt <<"EOF"
bind 1 split-window 'tmux switch-client -t SESSION_NAME_A'
bind 2 split-window 'tmux switch-client -t SESSION_NAME_B'
EOF

# echo "$HOME/.zsh_history_foo" > "$HOME/.check-files/zsh-history"

(cd ~/development/environment/ && bash ./src/main.sh)

tmux \
  new-session -s SESSION_NAME \; \
  send-keys 'cd ~/PATH/TO/FILE; clear' C-m \; \
\
  new-window \; \
  send-keys "echo foo" C-m \; \
\
  kill-session -t 0  \; \
  select-window -t 0 \;

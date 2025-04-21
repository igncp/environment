#!/usr/bin/env bash

if [ ! -f ~/development/environment/project/.config/minimal ]; then
  sudo pkill -f tmux
fi

cat >/tmp/tmux_bootstrap_bindings.txt <<"EOF"
#!/usr/bin/env bash

MAPPINGS=(
  "E_environment:0"
  "p_back-end:editor"
  "[_back-end:server"
  "'_back-end:docker"
)

echo 'Swiching:'
for i in "${MAPPINGS[@]}"; do
  LETTER="$(echo $i | cut -d'_' -f1)"
  NAME="$(echo $i | cut -d'_' -f2)"
  echo "$LETTER -> $NAME"
done

read_and_jump() {
  read -n1 SELECTION

  for i in "${MAPPINGS[@]}"; do
    LETTER="$(echo $i | cut -d'_' -f1)"
    if [[ "$SELECTION" == "$LETTER" ]]; then
      NAME="$(echo $i | cut -d'_' -f2)"
      tmux switch-client -t "$NAME"
      exit 0
    fi
  done

  read_and_jump
}

read_and_jump
EOF

cat >/tmp/tmux_jump_window.sh <<"EOF"
#!/usr/bin/env bash

echo 'Swiching'

read_and_jump() {
  read -n1 SELECTION

  if [ "$SELECTION" = "o" ]; then tmux switch-client -t "environment:0"
  else read_and_jump; fi
}

read_and_jump
EOF

# echo "$HOME/.zsh_history_foo" > "$HOME/.check-files/zsh-history"

(cd ~/development/environment/ && bash ./src/main.sh)

# \
# new-window \; \
# send-keys "echo foo" C-m \; \

tmux \
  new-session -s environment \; \
  send-keys 'cd ~/development/environment; clear' C-m \; \
  \
  kill-session -t 0 \; \
  select-window -t 0 \;

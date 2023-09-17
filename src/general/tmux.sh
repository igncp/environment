#!/usr/bin/env bash

set -e

install_tmux_plugin() {
  local REPONAME=$1
  local DIR=$(echo $REPONAME | cut -d'/' -f2)
  local FULL_DIR="$HOME/.tmux/plugins/$DIR"

  if [ ! -d "$FULL_DIR" ]; then
    mkdir -p ~/.tmux/plugins
    git clone --depth 1 -- "https://github.com/$REPONAME.git" $FULL_DIR
  fi

  echo "set -g @plugin '$REPONAME'" >>~/.tmux.conf
  sed -i "s|run '~/.tmux/plugins/tpm/tpm'||" ~/.tmux.conf
  echo "run '~/.tmux/plugins/tpm/tpm'" >>~/.tmux.conf
}

provision_setup_general_tmux() {
  install_system_package tmux

  cat >/tmp/tmux_choose_session.sh <<"EOF"
#!/usr/bin/env bash

SESSION=$(tmux ls | grep -o '^.*: ' | sed 's|: ||' | "$HOME"/.fzf/bin/fzf --color dark)

if [ -z "$SESSION" ]; then exit 0; fi

tmux switch-client -t "$SESSION"
EOF

  if [ -f /tmp/tmux_bootstrap_bindings.txt ]; then
    cat /tmp/tmux_bootstrap_bindings.txt >>~/.tmux.conf
  fi

  cat >~/.tmux.conf <<"EOF"
set-option -g default-shell $SHELL
set -s escape-time 0
set-window-option -g xterm-keys on

set -g status off
set -g status-right ""
set -g status-left ' [#(echo "$TMUX" | cut -f1 -d"," | sed -E "s|(/private)?/tmp/tmux-[0-9]*/||")]'
set -g status-left-length 50
set -g window-status-current-format ''
set -g window-status-format ''
set status-utf8 on
set utf8 on
set -g default-terminal "screen-256color"
set -g status-bg black
set -g status-fg red

bind-key S-Left swap-window -t -1
bind-key S-Right swap-window -t +1

bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# cycle through the panes in the window
bind -r Tab select-pane -t :.+

# keep your finger on ctrl, or don't
bind-key ^D detach-client

set -wg mode-style bg=white,fg=darkblue
set -wg message-style bg=white,fg=darkblue
set -wg mode-keys vi

new-session -n $HOST

set -g @copycat_search_C-t '\.test\.js:[0-9]'

unbind-key -T copy-mode-vi v
bind-key -T copy-mode-vi 'v' send -X begin-selection
bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
bind-key -T copy-mode-vi 'y' send -X copy-selection
bind-key -T copy-mode-vi 'd' send -X clear-selection

bind b split-window 'sh /tmp/tmux_choose_session.sh'
EOF

  install_tmux_plugin tmux-plugins/tpm
  install_tmux_plugin tmux-plugins/tmux-resurrect
  install_tmux_plugin tmux-plugins/tmux-sessionist
  install_tmux_plugin tmux-plugins/tmux-copycat

  if [ "$THEME" == "dark" ]; then
    sed -i 's|=white|=dark|' ~/.tmux.conf
    sed -i 's|=darkblue|=lightblue|' ~/.tmux.conf
    sed -i 's|--color=light|--color=dark|' /tmp/tmux_choose_session.sh
  fi
}

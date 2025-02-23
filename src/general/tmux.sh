#!/usr/bin/env bash

set -e

provision_setup_general_tmux() {
  cat >/tmp/tmux_choose_session.sh <<"EOF"
SESSION=$(tmux ls | grep -o '^.*: ' | sed 's|: ||' | fzf --color dark)
if [ -z "$SESSION" ]; then exit 0; fi
tmux switch-client -t "$SESSION"
EOF

  cat >/tmp/tmux_choose_window.sh <<"EOF"
WINDOW=$(tmux list-windows -a | sed 's|(.*||' | sed 's|\*||' | fzf --color dark)
if [ -z "$WINDOW" ]; then exit 0; fi
SESSION_NAME=$(echo "$WINDOW" | cut -f1 -d":")
WINDOW_INDEX=$(echo "$WINDOW" | cut -f2 -d":")
tmux switch-client -t "$SESSION_NAME:$WINDOW_INDEX"
EOF

  if [ -f ~/.config/tmux/tmux.conf ]; then
    rm -rf ~/.config/tmux/tmux.conf
  fi

  # Panes 組織方法:
  # - 找到 id `tmux list-panes -a`
  # - <leader> + o: 將 pane 移到該視窗
  # - <leader> + u: 將 pane 移出該視窗
  # - <leader> + !: 將 pane 移到新視窗
  # - <leader> + x: 關閉 pane
  # - <leader> + <space>: 循環垂直分割和水平分割
  # - <leader> + tab: 循環瀏覽視窗中的 panes

  if [ ! -d ~/.tmux/plugins/tpm ]; then
    mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  cat >~/.tmux.conf <<"EOF"
set-option -g default-shell $SHELL
set -s escape-time 0
set-window-option -g xterm-keys on
EOF

  install_tmux_plugin() {
    REPO=$1
    NAME=$(echo $REPO | sed 's|.*/||' | sed 's|\.git||')
    if [ ! -d ~/.tmux/plugins/$NAME ]; then
      git clone https://github.com/$REPO.git ~/.tmux/plugins/$NAME
    fi
    echo "set -g @plugin '$REPO'" >>~/.tmux.conf
  }

  install_tmux_plugin tmux-plugins/tmux-copycat
  install_tmux_plugin tmux-plugins/tmux-sessionist

  # ctrl+ b + j
  install_tmux_plugin schasse/tmux-jump

  cat >>~/.tmux.conf <<"EOF"
  set -g status off
  set -g status-right ""
  set -g status-left ' [#(echo "$TMUX" | cut -f1 -d"," | sed -E "s|(/private)?/tmp/tmux-[0-9]*/||")]'
  set -g status-left-length 50
  set -g window-status-current-format ""
  set -g window-status-format ""
  set -g default-terminal "screen-256color"

  set -g status-bg black
  set -g status-fg red

  bind-key S-Left swap-window -t -1
  bind-key S-Right swap-window -t +1

  bind '"' split-window -c "#{pane_current_path}"
  bind % split-window -h -c "#{pane_current_path}"
  bind c new-window -c "#{pane_current_path}"
  bind \} swap-pane -D \; select-pane -L

  # 循環瀏覽視窗中的窗格
  bind -r Tab select-pane -t :.+

  # keep your finger on ctrl, or don't
  bind-key ^D detach-client

  set -wg mode-keys vi

  new-session -n $HOST

  set -g @copycat_search_C-t '\.test\.js:[0-9]'

  unbind-key -T copy-mode-vi v

  bind-key -T copy-mode-vi 'v' send -X begin-selection
  bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
  bind-key -T copy-mode-vi 'V' send -X select-line
  bind-key -T copy-mode-vi 'y' send -X copy-selection
  bind-key -T copy-mode-vi 'd' send -X clear-selection

  # Pane movement
  bind-key o command-prompt -p "join pane from:" "join-pane -s '%%'"
  bind-key u command-prompt -p "send pane to:" "join-pane -t '%%'"

  bind b split-window 'bash /tmp/tmux_choose_session.sh'
  bind v split-window 'bash /tmp/tmux_choose_window.sh'

  run '~/.tmux/plugins/tpm/tpm'
EOF
}

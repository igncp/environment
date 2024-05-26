# Panes 組織方法:
# - 找到 id `tmux list-panes -a`
# - <leader> + o: 將 pane 移到該視窗
# - <leader> + u: 將 pane 移出該視窗
# - <leader> + !: 將 pane 移到新視窗
# - <leader> + x: 關閉 pane
# - <leader> + <space>: 循環垂直分割和水平分割
# - <leader> + tab: 循環瀏覽視窗中的 panes
{pkgs}: rec {
  plugins = with pkgs; [
    tmuxPlugins.copycat # https://github.com/tmux-plugins/tmux-copycat
    tmuxPlugins.jump # ctrl+ b + j # https://github.com/schasse/tmux-jump
    tmuxPlugins.sessionist # https://github.com/tmux-plugins/tmux-sessionist
  ];

  extraConfig = ''
    set-option -g default-shell $SHELL
    set -s escape-time 0
    set-window-option -g xterm-keys on

    set -g status off
    set -g status-right ""
    set -g status-left ' [#(echo "$TMUX" | cut -f1 -d"," | sed -E "s|(/private)?/tmp/tmux-[0-9]*/||")]'
    set -g status-left-length 50
    set -g window-status-current-format ""
    set -g window-status-format ""
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

    set -wg mode-style bg=dark,fg=lightblue
    set -wg message-style bg=dark,fg=lightblue
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
    bind-key o command-prompt -p "join pane from:"  "join-pane -s '%%'"
    bind-key u command-prompt -p "send pane to:"  "join-pane -t '%%'"

    bind b split-window 'sh /tmp/tmux_choose_session.sh'
  '';

  homeManager = {
    enable = true;
    extraConfig = extraConfig;
    plugins = plugins;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
  };
}

use std::path::Path;

use crate::base::{config::Theme, system::System, Context};

fn install_tmux_plugin(context: &mut Context, repo: &str) {
    let system = &context.system;
    let dir = repo.split('/').last().unwrap();
    let full_dir = format!("{}/.tmux/plugins/{}", context.system.home, dir);

    if !Path::new(&full_dir).exists() {
        std::fs::create_dir_all(system.get_home_path(".tmux/plugins")).unwrap();
        let full_repo = format!("https://github.com/{}.git", repo);

        System::run_bash_command(&format!("git clone --depth 1 -- {full_repo} {full_dir}"));
    }

    context.files.appendln(
        &system.get_home_path(".tmux.conf"),
        &format!("set -g @plugin '{}'", repo),
    );

    let mut tmux_conf = context
        .files
        .get(&system.get_home_path(".tmux.conf"))
        .replace("\nrun '~/.tmux/plugins/tpm/tpm'", "");

    tmux_conf.push_str("\nrun '~/.tmux/plugins/tpm/tpm'");

    context
        .files
        .set(&system.get_home_path(".tmux.conf"), &tmux_conf);
}

pub fn setup_tmux(context: &mut Context) {
    let tmux_file = context.system.get_home_path(".tmux.conf");

    context.system.install_system_package("tmux", None);

    context.files.append(
        &tmux_file,
        r###"
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
"###,
    );

    install_tmux_plugin(context, "tmux-plugins/tpm");
    install_tmux_plugin(context, "tmux-plugins/tmux-resurrect");
    install_tmux_plugin(context, "tmux-plugins/tmux-sessionist");
    install_tmux_plugin(context, "tmux-plugins/tmux-copycat");

    context.files.append(
        "/tmp/tmux_choose_session.sh",
        r###"
#!/usr/bin/env bash

SESSION=$(tmux ls | grep -o '^.*: ' | sed 's|: ||' | "$HOME"/.fzf/bin/fzf --color dark)

if [ -z "$SESSION" ]; then exit 0; fi

tmux switch-client -t "$SESSION"
"###,
    );

    if context.config.theme == Theme::Dark {
        let mut tmux_conf = context.files.get(&tmux_file);
        tmux_conf = tmux_conf.replace("=white", "=black");
        tmux_conf = tmux_conf.replace("=darkblue", "=lightblue");
        context
            .files
            .set(&context.system.get_home_path(".tmux.conf"), &tmux_conf);
    }

    if Path::new("/tmp/tmux_bootstrap_bindings.txt").exists() {
        let file_content = std::fs::read_to_string("/tmp/tmux_bootstrap_bindings.txt").unwrap();
        context.files.appendln(&tmux_file, &file_content);
    }

    // if [ ! -f ~/.tmux-completion.sh ]; then
    //   wget https://raw.githubusercontent.com/Bash-it/bash-it/4e730eb9a15c/completion/available/tmux.completion.bash \
    //     -O ~/.tmux-completion.sh
    // fi
    // echo 'source_if_exists ~/.tmux-completion.sh' >> ~/.bashrc
}

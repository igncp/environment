#!/usr/bin/env bash

set -e

provision_setup_general_tmux() {
  cat >/tmp/tmux_choose_session.sh <<"EOF"
#!/usr/bin/env bash

SESSION=$(tmux ls | grep -o '^.*: ' | sed 's|: ||' | fzf --color dark)

if [ -z "$SESSION" ]; then exit 0; fi

tmux switch-client -t "$SESSION"
EOF
}

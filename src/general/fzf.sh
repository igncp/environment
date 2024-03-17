#!/usr/bin/env bash

set -e

provision_setup_general_fzf() {
  install_system_package "ag"

  cat >>~/.shellrc <<"EOF"
export FZF_COMPLETION_TRIGGER='['
export FZF_DEFAULT_OPTS='--bind=pgup:preview-page-up,pgdn:preview-page-down,ctrl-j:preview-down,ctrl-k:preview-up --preview-window right:wrap --color=dark'
AG_DIRS() { ag -u --hidden --ignore .git -g "" "$@" | xargs dirname | sort | uniq; }
export FZF_ALT_C_COMMAND="AG_DIRS"
EOF

  cat >~/.bookmarked-commands <<"EOF"
GitEditorCommit
GitAddAll
GitDiff HEAD -- ':!*package-lock.json' ':!*yarn.lock' | less -r
git fetch
cp .git/COMMIT_EDITMSG /tmp/COMMIT_EDITMSG
git commit -m "$(head .git/COMMIT_EDITMSG  -n 1)"
EOF

  # Ctrl+t binding breaks window when tmux + (n)vim + ctrl-z: no visible input. Disable it
  # sed -i "s|C-t|C-$|" ~/.fzf/shell/key-bindings.bash

  cat >>~/.shellrc <<"EOF"
__FZFBookmarkedCommands() {
  cat ~/.bookmarked-commands |
  fzf --height 100% --border -m --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
}
__FZFScriptsRaw() {
  FILES=$(find ~/development/environment/src/scripts -mindepth 2 -type f ! -name "*.md" | grep -v node_modules | grep ".sh" | grep -v misc)
  FILES="$FILES\n$(find ~/.scripts/toolbox -type f)"
  echo "$FILES" | fzf --height 100% --border -m -q "'" --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
}
__FZFScripts() {
  $(__FZFScriptsRaw)
}
EOF

  cat >>~/.bashrc <<"EOF"
bind '"\er": redraw-current-line'
bind '"\C-q\C-q": "$(__FZFBookmarkedCommands)\e\C-e\er"'
bind '"\C-q\C-w": "$(__FZFBookmarkedCommands)\e\C-e\er\n"'
bind '"\C-q\C-a": "$(__FZFScripts)\e\C-e\er"'
bind '"\C-q\C-s": "$(__FZFScripts)\e\C-e\er\n"'
EOF
}

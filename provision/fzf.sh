# fzf START

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi
install_pacman_package the_silver_searcher ag
cat >> ~/.bashrc <<"EOF"
export FZF_COMPLETION_TRIGGER='['
AG_DIRS() { ag -u --hidden --ignore .git -g "" "$@" | xargs dirname | sort | uniq; }
export FZF_ALT_C_COMMAND="AG_DIRS"
EOF
# Ctrl+t binding breaks window when tmux + (n)vim + ctrl-z: no visible input. Disable it
sed -i "s|C-t|C-$|" ~/.fzf/shell/key-bindings.bash
cat >> ~/.bash_sources <<"EOF"
source_if_exists ~/.fzf.bash
EOF

cat >> ~/.bash_aliases <<"EOF"
fzf-down() {
  fzf --height 100% "$@" --border
}
__FZFGitStatusFile() {
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}
__FZFGitBranchesAllCheckout() {
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:60% \
    --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/origin/##' | sed 's#^origin/##' | sed 's#^#git checkout #'
}
__FZFGitDeleteLocalBranch() {
  git branch --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##' | sed 's#develop##' | sed 's#^#git branch -D #'
}
__FZFGitPushLocalBranch() {
  git branch --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -'$LINES |
  sed 's/^..//' | cut -d' ' -f1 | sed 's#^remotes/##' | sed 's#^#git push origin #'
}
__FZFGitLogResetCommit() {
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -'$LINES |
    grep -o "[a-f0-9]\{7,\}" | sed 's#^#git reset #'
}
__FZFGitReflogResetCommit() {
  git reflog --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'  |
    grep -o "[a-f0-9]\{7,\}" | sed 's#^#git reset #'
}
__FZFKillProcess() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then echo "sudo kill -9 $pid"; fi
}
__ShowFZFBindings(){
   printf "\n\n\n"; cat ~/.bash_fzf_bindings | tail -n +2 | sed 's#^bind ##; s#"##g; s#$(##; s#)\\e\\C-e\\er#\\e#' |
    sort | awk -v n=1 '1; NR % n == 0 {print "\n\n"}' | less
}
__FZFBookmarkedCommands() {
  cat ~/.bookmarked-commands |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
}
source ~/.bash_fzf_bindings
EOF
cat > ~/.bookmarked-commands <<"EOF"
GitCommit ""
GitEditorCommit
GitStatus
GitAddAll
GitDiff HEAD
git l
git fetch
EOF
cat > ~/.bash_fzf_bindings <<"EOF"
bind '"\C-a\C-s": "$(__FZFGitStatusFile)\e\C-e\er"'
bind '"\er": redraw-current-line'
bind '"\C-a\C-q": "$(__FZFBookmarkedCommands)\e\C-e\er"'
bind '"\C-a\C-w": "$(__FZFGitPushLocalBranch)\e\C-e\er"'
bind '"\C-a\C-f": "$(__FZFGitBranchesAllCheckout)\e\C-e\er"'
bind '"\C-a\C-t": "$(__FZFGitDeleteLocalBranch)\e\C-e\er"'
bind '"\C-a\C-l": "$(__FZFGitLogResetCommit)\e\C-e\er"'
bind '"\C-a\C-r": "$(__FZFGitReflogResetCommit)\e\C-e\er"'
bind '"\C-a\C-k": "$(__FZFKillProcess)\e\C-e\er"'
bind '"\C-a\C-a": "__ShowFZFBindings\n'
EOF

# fzf END

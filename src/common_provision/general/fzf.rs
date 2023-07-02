use std::path::Path;

use crate::base::{system::System, Context};

pub fn run_fzf(context: &mut Context) {
    if !Path::new(&context.system.get_home_path(".fzf")).exists() {
        System::run_bash_command(
            r###"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
"###,
        );
    }

    context.system.install_system_package("ag", None);

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export FZF_COMPLETION_TRIGGER='['
export FZF_DEFAULT_OPTS='--bind=pgup:preview-page-up,pgdn:preview-page-down,ctrl-j:preview-down,ctrl-k:preview-up --preview-window right:wrap --color=dark'
AG_DIRS() { ag -u --hidden --ignore .git -g "" "$@" | xargs dirname | sort | uniq; }
export FZF_ALT_C_COMMAND="AG_DIRS"
"###,
    );

    context.files.append(
        &context.system.get_home_path(".bookmarked-commands"),
        r###"
GitEditorCommit
GitAddAll
GitDiff HEAD -- ':!*package-lock.json' ':!*yarn.lock' | less -r
git fetch
cp .git/COMMIT_EDITMSG /tmp/COMMIT_EDITMSG
git commit -m "$(head .git/COMMIT_EDITMSG  -n 1)"
"###,
    );

    // Ctrl+t binding breaks window when tmux + (n)vim + ctrl-z: no visible input. Disable it
    //   sed -i "s|C-t|C-$|" ~/.fzf/shell/key-bindings.bash

    context.files.appendln(
        &context.system.get_home_path(".bashrc"),
        "source_if_exists ~/.fzf.bash",
    );
    context.files.appendln(
        &context.system.get_home_path(".zshrc"),
        "source_if_exists ~/.fzf.zsh",
    );

    std::fs::create_dir_all(
        context
            .system
            .get_home_path("development/environment/unix/scripts/custom"),
    )
    .unwrap();

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
__FZFBookmarkedCommands() {
  cat ~/.bookmarked-commands |
  fzf --height 100% --border -m --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
}
__FZFScriptsRaw() {
  FILES=$(find ~/development/environment/unix/scripts -mindepth 2 -type f ! -name "*.md" | grep -v node_modules | grep ".sh")
  FILES="$FILES\n$(find ~/.scripts/toolbox -type f)"
  echo "$FILES" | fzf --height 100% --border -m -q "'" --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' --header 'Press CTRL-S to toggle sort'
}
__FZFScripts() {
  $(__FZFScriptsRaw)
}
"###
    );

    context.files.append(
        &context.system.get_home_path(".bashrc"),
        r###"
bind '"\er": redraw-current-line'
bind '"\C-q\C-q": "$(__FZFBookmarkedCommands)\e\C-e\er"'
bind '"\C-q\C-w": "$(__FZFBookmarkedCommands)\e\C-e\er\n"'
bind '"\C-q\C-a": "$(__FZFScripts)\e\C-e\er"'
bind '"\C-q\C-s": "$(__FZFScripts)\e\C-e\er\n"'
"###,
    );
}

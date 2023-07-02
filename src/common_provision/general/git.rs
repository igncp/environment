use std::path::Path;

use crate::base::{config::Theme, system::System, Context};

pub fn run_git(context: &mut Context) {
    let mut initial_config = r###"
[user]
  email = foo@bar.com
  name = Foo Bar
[core]
  editor = vim
[alias]
  l = log --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %C(bold blue)%an %Cgreen%cd%Creset' --date=short
[pull]
  rebase = false
"###.to_string();

    if context.config.theme == Theme::Dark {
        initial_config.push_str(
            r###"
[color "diff-highlight"]
  oldNormal = "#d67a6f"
  oldHighlight = "#d67a6f reverse"
  newNormal = "#bdffcd"
  newHighlight = "#bdffcd reverse"
[color "diff"]
  meta = "#ffff77"
  frag = "#333333 #dddddd"
  func = "#666666 #dddddd"
  old = "#d67a6f"
  new = "#bdffcd"
  whitespace = "#0000ff reverse"
"###,
        );
    } else {
        initial_config.push_str(
            r###"
[color "diff-highlight"]
  oldNormal = "#bb0000"
  oldHighlight = "#bb0000 reverse"
  newNormal = "#009900"
  newHighlight = "#009900 reverse"
[color "diff"]
  meta = "#0000cc"
  frag = "#333333 #dddddd"
  func = "#666666 #dddddd"
  old = "#bb0000"
  new = "#009900"
  whitespace = "#0000ff reverse"
"###,
        );
    }

    context
        .files
        .append(&context.system.get_home_path(".gitconfig"), &initial_config);

    System::run_bash_command("git config --global pull.rebase false");

    if !Path::new("/usr/local/bin/git-extras").exists() {
        System::run_bash_command(
            r###"
rm -rf ~/.git-extras
git clone https://github.com/tj/git-extras.git ~/.git-extras
cd ~/.git-extras
git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
sudo make install
cd ~ && rm -rf ~/.git-extras
"###,
        );
    }

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
GitAdd() { git add -A $@; git status -u; }
GitCloneRepo() {
  SOURCE=$1; TARGET=$2;
  rm -rf "$TARGET"; mkdir -p "$TARGET";
  cp -r "$SOURCE"/.git "$TARGET"
  cd "$TARGET" && git reset --hard
  echo "Moved to target: $TARGET"
}
GitFilesAddedDiff() {
  GitAddAll 2>&1 > /dev/null;
  R_PATH="$(git rev-parse --show-toplevel)";
  git diff --name-only --diff-filter=A "$@" | sed 's|^|'"$R_PATH"'/|';
}
GitDiff() { git diff --color --relative $@; }
GitsShow() { git show --color $@; }
GitOpenStatusFiles() { $EDITOR -p $(git status --porcelain $1 | grep -vE "^ D" | sed s/^...//); }
GitPrintRemoteUrl() { git config --get "remote.${1:-origin}.url"; }
GitRemoteReset() {
  REMOTE_URL="$1"
  REMOTE_NAME="${2:-origin}";
  git remote rm "$REMOTE_NAME";
  git remote add "$REMOTE_NAME" "$REMOTE_URL";
  git remote -v
}
GitRemoteConvertToPrivate() {
  CURRENT_REMOTE=$( git config --get "remote.origin.url")
  NEW_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|_private.git$|.git|' | sed 's|\.git$|_private.git|')
  git remote rm origin ; git remote add origin "$NEW_REMOTE" ; git remote -v
}
GitRemoteConvertToPublic() {
  CURRENT_REMOTE=$( git config --get "remote.origin.url")
  NEW_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|_private.git$|.git|')
  git remote rm origin ; git remote add origin "$NEW_REMOTE" ; git remote -v
}
GitResetLastCommit() { LAST_COMMIT_MESSAGE=$(git log -1 --pretty=%B); \
  git reset --soft HEAD^; git add -A .; git commit -m "$LAST_COMMIT_MESSAGE"; }
GitRevertCode() { git reset "$1"; rm -rf "$1" ; git checkout -- "$1"; git status; }
GitFilesByAuthor() {
  DEFAULT_AUTHOR="$(git config user.name)"; AUTHOR="${1:-$DEFAULT_AUTHOR}"
  git log \
    --pretty="%H" \
    --author="$AUTHOR" \
  | while read commit_hash; do \
      git show --oneline --name-only $commit_hash | tail -n+2; \
    done \
  | sort | uniq | grep .
}
GitFilesByAuthorLatest() {
  git ls-files -z "$@" | \
    xargs --null -I % \
      sh -c "printf %' '; git annotate -p % | sed -nr '/^author /{s/^author (.*)/\1/;p}' | sort | uniq | awk '{printf (\$0 \" \")}END{print \"\"}'"
}
GitFilesByAuthorLatestGrep() {
  GitFilesByAuthorLatest "${@:2}" | grep -i "$1" | grep -o '^[^ ]* '
}

alias GitAddAll='GitAdd $(git rev-parse --show-toplevel)'
alias GitBranchOrder='git branch -r --sort=creatordate --format "%(creatordate:relative);%(committername);%(refname)" | sed "s|refs/remotes/origin/||" | grep -v ";HEAD$" | column -s ";" -t | tac | less'
GitCommit() { eval "git commit -m '$@'"; }
alias GitConfig='"$EDITOR" .git/config'
alias GitEditorCommit='git commit -v'
alias GitSameEditorCommit='git commit -v -t $(git rev-parse --show-toplevel)/.git/COMMIT_EDITMSG'
alias GitListConflictFiles='git diff --name-only --relative --diff-filter=U'
alias GitListFilesChangedHistory='git log --pretty=format: --name-only | sort | uniq -c | sort -rg' # can add `--author Foo`, --since, or remove files
alias GitRebaseResetAuthorContinue='git commit --amend --reset-author --no-edit; git rebase --continue'
alias GitRemotes='git remote -v'
alias GitStashApply='git stash apply' # can also use name here
alias GitStashList='git stash list'
alias GitStashName='git stash push -m'
alias GitSubmodulesUpdate='git submodule update --init --recursive' # clones existing submodules
    "###);
}

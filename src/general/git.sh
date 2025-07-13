#!/usr/bin/env bash

set -euo pipefail

provision_setup_general_git() {
  cat >>~/.shell_aliases <<"EOF"
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
GitDiff() { git diff --color $@; }
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
  git reset --soft HEAD^; git add -A .; git commit -m "$LAST_COMMIT_MESSAGE" $@; }
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

alias gbd="git branch -D"
alias ga='GitAdd'
alias gc="git checkout -B"
alias gca="git commit --amend"
alias gl="git l"
alias gp="git push"
alias gr="git remote -v"
alias grh="git reset --hard"
alias gs="git show"
alias gss='git commit -v -t $(git rev-parse --show-toplevel)/.git/COMMIT_EDITMSG'

gx() {
  BRANCH=${1:-main}
  git merge $BRANCH;
  git reset $(git merge-base HEAD $BRANCH);
}

gd() { git diff ${1:-HEAD} "${@:2}"; }
g() { eval "git commit -m '$@'"; }
gn() { eval "git commit --no-verify -m '$@'"; }

GitBranchOrder() {
  git branch $@ -a --sort=creatordate --format "%(creatordate:relative);%(committername);%(refname)" |
    sed "s|refs/remotes/origin/||" |
    grep -v ";HEAD$" |
    column -s ";" -t |
    tac | less;
}

alias GitAddAll='GitAdd $(git rev-parse --show-toplevel)'
alias GitBranchesCompare='git log --left-right --graph --cherry-pick --oneline' # e.g. GitBranchesCompare main...feature
alias GitCleanAll='git clean -fxd' # 包括被忽略的檔案（例如 .env 檔案）
alias GitConfig='"$EDITOR" .git/config'
alias GitEditorCommit='git commit -v'
alias GitListConflictFiles='git diff --name-only --relative --diff-filter=U'
alias GitListFilesChangedHistory='git log --pretty=format: --name-only | sort | uniq -c | sort -rg' # can add `--author Foo`, --since, or remove files
alias GitRebaseResetAuthorContinue='git commit --amend --reset-author --no-edit; git rebase --continue'
alias GitRemotes='git remote -v'
alias GitStashApply='git stash apply' # can also use name here
alias GitStashList='git stash list'
alias GitStashName='git stash push -m'
alias GitSubmodulesUpdate='git submodule update --init --recursive' # clones existing submodules

# For example: `GitConfigureRepoSSH ~/.ssh/foo`
GitConfigureRepoSSH() {
  if [ -z "$1" ]; then echo "Missing SSH key path" && return; fi
  if [ ! -f "$1" ]; then echo "The file path does not exist" && return; fi
  git config core.sshCommand "ssh -i $1 -F /dev/null"
}
EOF

  cat >~/.gitconfig <<"EOF"
[user]
  email = foo@bar.com
  name = Foo Bar
[core]
  editor = vim
  # 改進終端中 unicode 字元的顯示 (例如文件中的漢字)
  quotepath = off
[alias]
  l = log --pretty=format:'%Cred%h%Creset%C(yellow)%d%Creset %s %C(bold blue)%an %Cgreen%cd%Creset' --date=short
[pull]
  rebase = false
EOF

  if [ "$THEME" == "dark" ]; then
    cat >>~/.gitconfig <<"EOF"
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
EOF
  else
    cat >>~/.gitconfig <<"EOF"
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
EOF
  fi

  git config --global pull.rebase false
  git config --global push.autoSetupRemote true
}

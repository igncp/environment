#!/usr/bin/env bash

set -euo pipefail

provision_setup_cli_tools_github() {
  cat >>~/.shell_aliases <<"EOF"
alias gh='NO_COLOR=1 gh'
alias GHDeployments="gh api repos/{owner}/{repo}/deployments | jq | ag web_url | sort | uniq | less"
alias GHAuthLogin="gh auth login"
alias GHRepoList="gh repo list" # For example: GHRepoList igncp
alias GHRepoClone="gh repo clone" # For example: GHRepoClone igncp/environment
EOF

  if [ ! -f "$HOME"/.gh-completion-bash ]; then
    gh completion --shell zsh >~/.oh-my-zsh/custom/plugins/zsh-completions/_gh
    gh config set editor vim
    gh completion --shell bash >~/.gh-completion-bash
    echo '~/.gh-completion-bash generated'
  fi

  echo 'source_if_exists $HOME/.gh-completion-bash' >>~/.bashrc
}

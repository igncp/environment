use std::path::Path;

use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_gh(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/cli-gh") {
        return;
    }

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias gh='NO_COLOR=1 gh'
alias GHDeployments="gh api repos/{owner}/{repo}/deployments | jq | ag web_url | sort | uniq | less"
alias GHAuthLogin="gh auth login"
alias GHRepoList="gh repo list" # For example: GHRepoList igncp
alias GHRepoClone="gh repo clone" # For example: GHRepoClone igncp/environment
"###,
    );

    if !Path::new(&context.system.get_home_path(".gh-completion-bash")).exists() {
        System::run_bash_command(
            r###"
gh completion --shell bash > ~/.gh-completion-bash
gh completion --shell zsh > "$HOME"/.oh-my-zsh/custom/plugins/zsh-completions/_gh
echo '~/.gh-completion generated'
gh config set editor vim
"###,
        );
    }

    context.files.appendln(
        &context.system.get_home_path(".bashrc"),
        "source_if_exists $HOME/.gh-completion-bash",
    );
}

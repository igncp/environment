use std::path::Path;

use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_gh(context: &mut Context) {
    if Config::has_config_file(&context.system, "cli-gh") {
        if !context.system.get_has_binary("gh") {
            System::run_bash_command("cd ~; rm -rf gh_cli; mkdir -p gh_cli; cd gh_cli");
            if context.system.is_mac() {
                context.system.install_system_package("gh", None);
            } else {
                if context.system.is_arm() {
                    System::run_bash_command("wget https://github.com/cli/cli/releases/download/v2.21.1/gh_2.21.1_linux_arm64.tar.gz");
                } else {
                    System::run_bash_command("wget https://github.com/cli/cli/releases/download/v2.21.1/gh_2.21.1_linux_amd64.tar.gz");
                }

                System::run_bash_command(
                    r###"
tar xvzf *.tar.gz
rm -rf *.tar.gz
sudo mv gh_*/bin/gh /usr/local/bin
cd ~; rm -rf gh_cli
"###,
                );
            }
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
}

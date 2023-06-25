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
}

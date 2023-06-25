use crate::base::{system::System, Context};
use crate::common_provision::update_vim_colors_theme;

use std::path::Path;

fn clone_dev_github_repo(context: &mut Context, repo: &str) {
    let dir_path = context.system.get_home_path(&format!("development/{repo}"));

    if !Path::new(&dir_path).exists() {
        System::run_bash_command(&format!(
            r#"git clone "git@github.com:igncp/{repo}.git" "{dir_path}""#
        ));
    }
}

#[allow(dead_code)]
pub fn run_custom(context: &mut Context) {
    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
if [ -z "$TMUX" ]; then
  echo 'check if running in VM and remove condition if yes, either way remove this message'
  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo 'ssh, not running tmux'
  elif [ "$(tmux list-clients 2> /dev/null | wc -l | tr '\n' '_')" != "0_" ]; then
    echo 'there is already a tmux client, not attaching to session'
  elif [ -n "$(pgrep tmux)" ]; then
    tmux attach
  elif [ -f "$HOME"/development/environment/unix/scripts/bootstrap/Bootstrap_common.sh ]; then
    sh "$HOME"/development/environment/unix/scripts/bootstrap/Bootstrap_common.sh
  elif [ ! -f $HOME/development/environment/project/.config/no-auto-tmux ]; then
    tmux
  fi
fi
"###,
    );

    context.write_file(&context.system.get_home_path(".gitconfig"), true);

    System::run_bash_command(
        r###"
# git config --global user.name 'Foo Bar'
# git config --global user.email foo@bar.com
# git config --global gpg.format ssh
# git config --global commit.gpgsign true
# git config --global user.signingkey '...' # Public SSH key
# git config --global core.editor nvim
## If using 1Password directly Linux, this is needed
# git config --global gpg.ssh.program /opt/1Password/op-ssh-sign
# mkdir -p "$HOME"/.config/git/git
# git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
# # This file is used for `git log --show-signature`, have to add the public key instead of `...`
# echo "icarbajop@gmail.com ..." > "$HOME"/.config/git/allowed_signers
if [ ! -f "$HOME"/.check-files/git-info ]; then
  echo '[~/.check-files/git-info]: configure git user and email info'
fi
git config --global core.editor nvim
"###,
    );

    let vim_env_setup = r###"
function! SetupEnvironment()
  let l:path = expand('%:p')
  if l:path =~ '_HOME_foo/bar'
    let g:Fast_grep='. --exclude-dir={node_modules,dist,.git,coverage} --exclude="*.log"'
  elseif l:path =~ '_HOME_bar/baz'
    let g:Fast_grep='main'
  else
    let g:Fast_grep='src'
  endif
endfunction
autocmd! BufReadPost,BufNewFile * call SetupEnvironment()
"###
    .replace("_HOME_", &context.system.get_home_path(""));

    context
        .files
        .append(&context.system.get_home_path(".vimrc"), &vim_env_setup);

    clone_dev_github_repo(context, "environment");

    if Path::new(&context.system.get_home_path(".config/coc-settings.json")).exists() {
        System::run_bash_command(
            r#"jq -S "." ~/.vim/coc-settings.json | sponge ~/.vim/coc-settings.json"#,
        );
    }

    update_vim_colors_theme(context);

    context.files.replace(
        &context.system.get_home_path(".shellrc"),
        "--color=light",
        "--color=dark",
    );

    context.files.replace(
        "/tmp/tmux_choose_session.sh",
        "--color=light",
        "--color=dark",
    );
}

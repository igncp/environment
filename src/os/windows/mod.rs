use std::path::Path;

use crate::base::{system::System, Context};

use self::{komorebi::setup_komorebi, utils::install_windows_package, vscode::run_windows_vscode};

use super::get_vim_multi_os_provision;

pub use self::utils::append_json_into_vs_code;

mod komorebi;
mod utils;
mod vscode;

fn check_ahk_shortcut(context: &mut Context, file_name: &str) {
    if !Path::new(&context.system.get_home_path(&format!(
        "AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\{}.lnk",
        file_name
    )))
    .exists()
    {
        println!("Open the startup dir with 'ExplorerStartup' and create a shortcut for '{}'", file_name);
    }
}

pub fn run_windows(context: &mut Context) {
    let current_shell = std::env::var_os("SHELL");
    if current_shell.is_none() {
        println!("Windows provision is only supported in Git Bash");
        std::process::exit(1);
    }

    let current_shell = current_shell.unwrap().to_str().unwrap_or("_").to_string();
    if !current_shell.contains("bash") {
        println!("Windows provision is only supported in Git Bash");
        std::process::exit(1);
    }

    run_windows_vscode(context);

    install_windows_package(context, "RARLab.WinRAR", "WinRAR");
    install_windows_package(context, "AutoHotkey.AutoHotkey", "AutoHotkey.lnk");
    install_windows_package(context, "tailscale.tailscale", "Tailscale.lnk");
    install_windows_package(context, "AgileBits.1Password", "1Password.lnk");

    context.files.append(
        &context.system.get_home_path(".bash_profile"),
        r###"
cd ~/development/environment

alias n='nvim'
alias l="less -i"
alias rm='rm -rf'
alias e='explorer.exe'
alias ag="ag --hidden  --color-match 7"
alias agg='ag --hidden --ignore node_modules --ignore .git'
alias cp="cp -r"
alias ll="ls -lah --color=always"
alias mkdir="mkdir -p"
alias tree="tree -a"

alias ExplorerStartup='(cd $APPDATA/Microsoft/Windows/Start\ Menu/Programs/Startup/ && explorer.exe .)'
alias ExplorerEnvironment='(cd $USERPROFILE/development/environment && explorer.exe .)'
alias Provision="(cd ~/development/environment && cargo run --release)"

GitAdd() { git add -A $@; git status -u; }
GitCommit() { eval "git commit -m '$@'"; }
"###,
    );

    std::fs::create_dir_all(context.system.get_home_path("AppData\\Local\\nvim")).unwrap();

    System::run_bash_command(
        r###"
if ! type "jq" > /dev/null; then
    echo "Run the following command as an administrator to install jq:"
    echo curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe
fi
"###,
    );

    let vim_str = get_vim_multi_os_provision();
    let vim_str = format!(
        r###"
{}
" Save file shortcuts
nmap <c-e> :update<esc>
inoremap <c-e> <esc>:update<cr>
"###,
        vim_str
    );

    context
        .files
        .append(&context.system.get_home_path(".vimrc"), &vim_str);

    context.files.append(
        &context
            .system
            .get_home_path("AppData\\Local\\nvim\\init.vim"),
        &vim_str,
    );

    context
        .system
        .install_system_package("JFLarvoire.Ag", Some("ag.exe"));
    context
        .system
        .install_system_package("junegunn.fzf", Some("fzf.exe"));

    check_ahk_shortcut(context, "switch-same-app.ahk");
    check_ahk_shortcut(context, "capslock.ahk");

    setup_komorebi(context);
}

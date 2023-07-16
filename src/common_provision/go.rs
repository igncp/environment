use std::path::Path;

use crate::base::{config::Config, system::System, Context};

use super::vim::install_nvim_package;

const VERSION: &str = "1.20.5";

fn get_goroot() -> String {
    format!("$HOME/.asdf/installs/golang/{VERSION}/go")
}

fn install_go_package(context: &mut Context, pkg: &str, cmd: &str) {
    if !Path::new(
        &context
            .system
            .get_home_path(&format!(".asdf/installs/golang/{VERSION}/go/bin/{cmd}")),
    )
    .exists()
    {
        println!("Installing the go package: {}", pkg);
        System::run_bash_command(&format!("go install {}", pkg));
    }
}

pub fn setup_go(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/go") {
        return;
    }

    let goroot = get_goroot();

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        &format!(
            r###"
export GOROOT="{goroot}"
export GOPATH="$HOME/.go-workspace"
export GOBIN="$GOROOT/bin"
export GO15VENDOREXPERIMENT=1
export PATH=$PATH:$GOPATH/bin:$GOBIN
"###,
        ),
    );

    if !context.system.get_has_binary("go") {
        println!("Installing go");

        System::run_bash_command(
            r###"
. $HOME/.asdf/asdf.sh
(asdf plugin-add golang https://github.com/kennyp/asdf-golang.git || true)
asdf install golang 1.20.5
asdf global golang 1.20.5
"###,
        )
    }

    install_nvim_package(context, "josa42/coc-go", None);
    install_nvim_package(context, "fatih/vim-go", None);

    if !context.system.is_nixos() {
        install_go_package(context, "github.com/kisielk/errcheck@latest", "errcheck");
        install_go_package(context, "github.com/google/pprof@latest", "pprof"); // https://github.com/google/pprof
    }

    context.files.appendln(
        &context.system.get_home_path(".vimrc"),
        r###"
call add(g:coc_global_extensions, 'coc-go')

" TODO: Alias for printing a log
let GoPrintMapping="vnoremap <leader>kk yOprintln!(\"a {:?}\", a);<C-c>11hvpgvyf\"lllvp"
autocmd filetype go :exe GoPrintMapping

let g:go_def_mapping_enabled = 0
let g:go_doc_keywordprg_enabled = 0
"###,
    );

    if Config::has_config_file(&context.system, ".config/go-cosmos")
        && !context.system.get_has_binary("ignite")
    {
        let ignite_version = "v0.22.1";

        System::run_bash_command(&format!(
            "curl https://get.ignite.com/cli@{ignite_version}! | bash"
        ))
    }
}

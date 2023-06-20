use std::path::Path;

use crate::base::{config::Config, system::System, Context};

use super::vim::install_nvim_package;

const VERSION: &str = "1.20.5";

fn install_go_package(context: &mut Context, pkg: &str, cmd: &str) {
    if !Path::new(&context.system.get_home_path(&format!(
        ".asdf/installs/golang/{VERSION}/packages/bin/{cmd}"
    )))
    .exists()
    {
        println!("Installing go package {}", pkg);
        System::run_bash_command(&format!("go install {}", pkg));
    }
}

pub fn setup_go(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/go") {
        return;
    }

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export GOROOT="$HOME/.asdf/plugins/golang"
export GOPATH="$HOME/.go-workspace"
export GOBIN="$GOROOT/bin"
export GO15VENDOREXPERIMENT=1
export PATH=$PATH:$GOPATH/bin:$GOBIN
"###,
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

    install_go_package(context, "github.com/kisielk/errcheck@latest", "errcheck");

    install_nvim_package(context, "josa42/coc-go", None);
    install_nvim_package(context, "fatih/vim-go", None);
}

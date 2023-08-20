use crate::base::{config::Config, system::System, Context};

use super::vim::install_nvim_package;

pub fn setup_go(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/go") {
        return;
    }

    context.home_append(
        ".shellrc",
        &format!(
            r###"
    export GOPATH="$HOME/.go-workspace"
    export GO15VENDOREXPERIMENT=1
    export PATH=$PATH:$GOPATH/bin
    "###,
        ),
    );

    context.home_append(
        ".shell_aliases",
        r###"
# This is for vim-go
GoInitEditor() {
    (cd ~ && go install golang.org/x/tools/gopls@latest)
    echo "You have to run :GoInstallBinaries inside nvim"
}
    "###,
    );

    install_nvim_package(context, "josa42/coc-go", None);
    install_nvim_package(context, "fatih/vim-go", None);

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

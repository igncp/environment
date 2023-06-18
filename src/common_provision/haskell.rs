use crate::base::{config::Config, Context};

use super::vim::install_nvim_package;

pub fn setup_haskell(context: &mut Context) {
    if !Config::has_config_file(&context.system, "haskell") {
        return;
    }

    context.system.install_system_package("ghc", None);
    context.system.install_system_package("stack", None);

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export PATH=$PATH:/usr/local/lib/stack/bin
export PATH=$PATH:~/.cabal/bin
"###,
    );

    context.files.append(
        &context.system.get_home_path(".bashrc"),
        r###"
eval "$(stack --bash-completion-script stack)"
"###,
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias runghc="stack exec runghc --silent -- -w -ihs"
alias vim="stack exec vim"
"###,
    );

    install_nvim_package(
        context,
        "eagletmt/ghcmod-vim",
        Some("stack install ghc-mod"),
    );
    install_nvim_package(context, "neovimhaskell/haskell-vim", None);
    install_nvim_package(
        context,
        "nbouscal/vim-stylish-haskell",
        Some("stylish-haskell --defaults > ~/.stylish-haskell.yaml"),
    );

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
autocmd BufWritePost *.hs :GhcModCheckAsync
autocmd BufReadPost *.hs :GhcModCheckAsync
"###,
    );
}

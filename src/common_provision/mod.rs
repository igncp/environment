use crate::base::Context;

pub use self::vim::update_vim_colors_theme;
use self::{
    android::setup_android,
    brightscript::setup_brightscript,
    c::setup_c,
    cli_tools::run_cli_tools,
    dart::setup_dart,
    docker::setup_docker,
    dotnet::setup_dotnet,
    general::{run_general, run_general_end},
    go::setup_go,
    haskell::setup_haskell,
    js::{run_js, setup_js_vue},
    kotlin::setup_kotlin,
    linux::setup_linux,
    nix::setup_nix,
    php::setup_php,
    raspberry::setup_raspberry,
    ruby::setup_ruby,
    rust::setup_rust,
    vim::{run_nvim_coc, run_vim},
    zsh::run_zsh,
};

mod android;
mod brightscript;
mod c;
mod cli_tools;
mod dart;
mod docker;
mod dotnet;
mod general;
mod go;
mod haskell;
mod js;
mod kotlin;
mod linux;
mod nix;
mod php;
mod raspberry;
mod ruby;
mod rust;
mod vim;
mod zsh;

pub fn run_common_provision(context: &mut Context) {
    setup_nix(context);
    run_zsh(context);
    run_general(context);

    if context.system.is_linux() {
        setup_linux(context);
    }

    run_vim(context);
    run_js(context);
    run_nvim_coc(context);
    run_cli_tools(context);
    setup_js_vue(context);
    setup_rust(context);
    setup_go(context);
    setup_ruby(context);
    setup_raspberry(context);
    setup_c(context);
    setup_brightscript(context);
    setup_docker(context);
    setup_dotnet(context);
    setup_php(context);
    setup_kotlin(context);
    setup_haskell(context);
    setup_dart(context);
    setup_android(context);

    run_general_end(context);
}

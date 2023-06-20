use std::path::Path;

use crate::base::{config::Config, system::System, Context};

use super::vim::install_nvim_package;

// It expects a bin file for each crate
fn install_cargo_crate(context: &mut Context, crate_name: &str, bin_name: Option<&str>) {
    let bin = bin_name.unwrap_or(crate_name);

    if !Path::new(&format!("{}/.cargo/bin/{}", context.system.home, bin)).exists() {
        println!("Installing crate: {}", crate_name);
        System::run_bash_command(&format!("cargo install {crate_name}"));
    }
}

pub fn setup_rust(context: &mut Context) {
    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias CargoClippy='CMD="# rm -rf target && cargo clippy --all-targets --all-features -- -D warnings"; echo $CMD; history -s $CMD'
"###,
    );

    install_nvim_package(context, "rust-lang/rust.vim", None);
    install_nvim_package(context, "cespare/vim-toml", None);

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
let g:rustfmt_autosave = 1

let RustPrintMapping="vnoremap <leader>kk yOprintln!(\"a {:?}\", a);<C-c>11hvpgvyf\"lllvp"
autocmd filetype rust :exe RustPrintMapping
"###,
    );

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export PASTEL_COLOR_MODE=24bit
"###,
    );

    if !context.system.is_mac() {
        context.system.install_system_package("valgrind", None);
    }

    install_nvim_package(context, "fannheyward/coc-rust-analyzer", None);

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
call add(g:coc_global_extensions, 'coc-rust-analyzer')
nnoremap <leader>lr :CocCommand rust-analyzer.reload<CR>
nnoremap <leader>lx :CocCommand rust-analyzer.explainError<CR>
nnoremap <leader>lj :CocCommand rust-analyzer.moveItemDown<CR>
nnoremap <leader>lk :CocCommand rust-analyzer.moveItemUp<CR>
"###,
    );

    install_cargo_crate(context, "rustfmt", None); // https://github.com/rust-lang/rustfmt

    if Config::has_config_file(&context.system, ".config/extra-crates") {
        context.system.install_system_package("perf", None);
        install_cargo_crate(context, "flamegraph", None); // https://github.com/flamegraph-rs/flamegraph
        install_cargo_crate(context, "cargo-bloat", None); // https://github.com/RazrFalcon/cargo-bloat
        install_cargo_crate(context, "cargo-unused-features", Some("unused-features")); // https://github.com/TimonPost/cargo-unused-features
        install_cargo_crate(context, "pastel", None); // https://github.com/sharkdp/pastel
    }

    context.files.appendln(
        &context.system.get_home_path(".vim/colors.vim"),
        r###"
hi rustCommentLineDoc    cterm=NONE ctermfg=cyan  ctermbg=white
hi rustAttribute    cterm=NONE ctermfg=cyan  ctermbg=white
hi rustDerive    cterm=NONE ctermfg=cyan  ctermbg=white
hi rustDeriveTrait    cterm=NONE ctermfg=cyan  ctermbg=white
"###,
    );

    if !context.system.get_has_binary("cargo-clippy") {
        System::run_bash_command("rustup component add clippy");
    }

    // Will add commands like: `cargo add`, `cargo rm` and `cargo upgrade`
    if !context.system.get_has_binary("cargo-add") {
        System::run_bash_command("cargo install cargo-edit");
    }

    context.files.append_json(
        &context.system.get_home_path(".vim/coc-settings.json"),
        r###"
"rust-analyzer.inlayHints.bindingModeHints.enable": false,
"rust-analyzer.inlayHints.chainingHints.enable": false,
"rust-analyzer.inlayHints.closingBraceHints.enable": false,
"rust-analyzer.inlayHints.closureReturnTypeHints.enable": false,
"rust-analyzer.inlayHints.lifetimeElisionHints.enable": false,
"rust-analyzer.inlayHints.parameterHints.enable": false,
"rust-analyzer.inlayHints.reborrowHints.enable": false,
"rust-analyzer.inlayHints.typeHints.enable": false,
"rust-analyzer.checkOnSave.command":"clippy"
"###,
    );

    if Config::has_config_file(&context.system, ".config/rust-cross-compile") {
        System::run_bash_command(
            r###"
if [ ! -f ~/.check-files/rust-cross-compile ] && type "apt-get" > /dev/null 2>&1; then
    # TODO: generalize installation for arch linux
    sudo apt-get install -y gcc-x86-64-linux-gnu
    rustup target add x86_64-unknown-linux-musl

    # export CC_x86_64_unknown_linux_musl=x86_64-linux-gnu-gcc
    # export RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc'

    touch ~/.check-files/rust-cross-compile
fi
"###,
        );
    }
}

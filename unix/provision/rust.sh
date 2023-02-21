# rust START

cat >> ~/.shellrc <<"EOF"
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi
EOF

if [ -f "$HOME"/.cargo/env ]; then source "$HOME/.cargo/env"; fi # in case provision stopped before

if ! type rustc > /dev/null 2>&1 ; then
  curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y --default-toolchain nightly
  source "$HOME/.cargo/env"
  rustup component add rust-src
  cargo install cargo-edit
fi

if ! type cargo-clippy > /dev/null 2>&1 ; then
  rustup component add clippy
fi

if ! type cargo-add > /dev/null 2>&1 ; then
  # will add commands like: `cargo add`, `cargo rm` and `cargo upgrade`
  cargo install cargo-edit
fi

cat >> ~/.shell_aliases <<"EOF"
alias CargoClippy='CMD="# rm -rf target && cargo clippy --all-targets --all-features -- -D warnings"; echo $CMD; history -s $CMD'
EOF

install_vim_package rust-lang/rust.vim
install_vim_package cespare/vim-toml

cat >> ~/.vimrc <<"EOF"
let g:rustfmt_autosave = 1

let RustPrintMapping="vnoremap <leader>kk yOprintln!(\"a {:?}\", a);<C-c>11hvpgvyf\"lllvp"
autocmd filetype rust :exe RustPrintMapping
EOF

cat >> ~/.vim/colors.vim <<"EOF"
hi rustCommentLineDoc    cterm=NONE ctermfg=cyan  ctermbg=white
hi rustAttribute    cterm=NONE ctermfg=cyan  ctermbg=white
hi rustDerive    cterm=NONE ctermfg=cyan  ctermbg=white
hi rustDeriveTrait    cterm=NONE ctermfg=cyan  ctermbg=white
EOF

# it expects a bin file for each crate
install_cargo_crate() {
  CRATE="$1";
  if [[ ! -z "$2" ]]; then BIN_FILE_NAME="$2"; else BIN_FILE_NAME="$1"; fi
  if [ ! -f ~/.cargo/bin/"$BIN_FILE_NAME" ] ; then
    echo "doing: cargo install $CRATE"
    cargo install $CRATE
  fi
}

install_cargo_crate rustfmt # https://github.com/rust-lang/rustfmt
install_cargo_crate cargo-bloat # https://github.com/RazrFalcon/cargo-bloat
install_cargo_crate cargo-unused-features unused-features # https://github.com/TimonPost/cargo-unused-features
install_cargo_crate pastel # https://github.com/sharkdp/pastel

cat >> ~/.shellrc <<"EOF"
export PASTEL_COLOR_MODE=24bit
EOF

install_system_package valgrind

install_vim_package fannheyward/coc-rust-analyzer
cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-rust-analyzer')
nnoremap <leader>lr :CocCommand rust-analyzer.reload<CR>
nnoremap <leader>lx :CocCommand rust-analyzer.explainError<CR>
nnoremap <leader>lj :CocCommand rust-analyzer.moveItemDown<CR>
nnoremap <leader>lk :CocCommand rust-analyzer.moveItemUp<CR>
EOF

jq \
  '."rust-analyzer.inlayHints.bindingModeHints.enable" = false
   | ."rust-analyzer.inlayHints.chainingHints.enable" = false
   | ."rust-analyzer.inlayHints.closingBraceHints.enable" = false
   | ."rust-analyzer.inlayHints.closureReturnTypeHints.enable" = false
   | ."rust-analyzer.inlayHints.lifetimeElisionHints.enable" = false
   | ."rust-analyzer.inlayHints.parameterHints.enable" = false
   | ."rust-analyzer.inlayHints.reborrowHints.enable" = false
   | ."rust-analyzer.inlayHints.typeHints.enable" = false
   | ."rust-analyzer.checkOnSave.command" = "clippy"
  ' ~/.vim/coc-settings.json | sponge ~/.vim/coc-settings.json

if [ -f ~/project/.config/rust-cross-compile ]; then
  if [ ! -f ~/.check-files/rust-cross-compile ] && type "apt-get" > /dev/null 2>&1; then
    # TODO: generalize installation for arch linux
    sudo apt-get install -y gcc-x86-64-linux-gnu
    rustup target add x86_64-unknown-linux-musl

    # export CC_x86_64_unknown_linux_musl=x86_64-linux-gnu-gcc
    # export RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc'

    touch ~/.check-files/rust-cross-compile
  fi
fi

# rust END

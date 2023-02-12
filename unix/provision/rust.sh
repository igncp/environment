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

if ! type cargo-add > /dev/null 2>&1 ; then
  # will add commands like: `cargo add`, `cargo rm` and `cargo upgrade`
  cargo install cargo-edit
fi

cat >> ~/.shell_aliases <<"EOF"
alias CargoClippy='CMD="# rm -rf target && cargo clippy --all-targets --all-features -- -D warnings"; echo $CMD; history -s $CMD'
EOF

install_vim_package rust-lang/rust.vim
install_vim_package mattn/webapi-vim
install_vim_package cespare/vim-toml

# if rustfmt doesn't work
  # https://github.com/rust-lang/rustfmt/issues/3404
  # rustup toolchain add nightly-2019-02-08
  # rustup component add --toolchain nightly-2019-02-08 rustfmt clippy
  # rustup default nightly-2019-02-08

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

install_cargo_crate rustfmt
install_cargo_crate pastel # https://github.com/sharkdp/pastel

cat >> ~/.shellrc <<"EOF"
export PASTEL_COLOR_MODE=24bit
EOF

install_system_package valgrind

# for C bindings
install_system_package clang # for bindgen
if ! type "$CMD_CHECK" > /dev/null 2>&1 ; then
  cargo install bindgen
fi

install_vim_package fannheyward/coc-rust-analyzer
cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-rust-analyzer')
EOF

# rust END

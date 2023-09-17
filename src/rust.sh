#!/usr/bin/env bash

set -e

install_cargo_crate() {
  NAME="$1"
  BIN="${2:-$NAME}"

  if ! type "$BIN" >/dev/null 2>&1; then
    if [ ! -f ~/.cargo/bin/"$BIN" ]; then
      echo "Installing cargo crate: $NAME"

      cargo install "$NAME"
    fi
  fi
}

provision_setup_rust() {
  cat >>~/.shell_aliases <<"EOF"
alias CargoClippy='CMD="# rm -rf target && cargo clippy --all-targets --all-features -- -D warnings"; echo $CMD; history -s $CMD'
EOF

  install_nvim_package cespare/vim-toml
  install_nvim_package rust-lang/rust.vim

  cat >>~/.vimrc <<"EOF"
let g:rustfmt_autosave = 1

let RustPrintMapping="vnoremap <leader>kk yOprintln!(\"a {:?}\", a);<C-c>11hvpgvyf\"lllvp"
autocmd filetype rust :exe RustPrintMapping

call add(g:coc_global_extensions, 'coc-rust-analyzer')
nnoremap <leader>lr :CocCommand rust-analyzer.reload<CR>
nnoremap <leader>lx :CocCommand rust-analyzer.explainError<CR>
nnoremap <leader>lj :CocCommand rust-analyzer.moveItemDown<CR>
nnoremap <leader>lk :CocCommand rust-analyzer.moveItemUp<CR>
EOF

  cat >>~/.shellrc <<"EOF"
export PASTEL_COLOR_MODE=24bit
EOF

  install_nvim_package fannheyward/coc-rust-analyzer

  if ! type cargo-clippy >/dev/null 2>&1; then
    rustup component add clippy
  fi

  if [ -f "$PROVISION_CONFIG"/rust-cross-compile ]; then
    if [ ! -f ~/.check-files/rust-cross-compile ] && type "apt-get" >/dev/null 2>&1; then
      # TODO: generalize installation for arch linux
      sudo apt-get install -y gcc-x86-64-linux-gnu
      rustup target add x86_64-unknown-linux-musl

      # export CC_x86_64_unknown_linux_musl=x86_64-linux-gnu-gcc
      # export RUSTFLAGS='-C linker=x86_64-linux-gnu-gcc'

      touch ~/.check-files/rust-cross-compile
    fi
  fi

  install_cargo_crate rustfmt # https://github.com/rust-lang/rustfmt

  if [ -f "$PROVISION_CONFIG"/extra-crates ]; then
    install_system_package perf

    # https://github.com/flamegraph-rs/flamegraph
    install_cargo_crate flamegraph

    # https://github.com/RazrFalcon/cargo-bloat
    install_cargo_crate cargo-bloat

    # https://github.com/TimonPost/cargo-unused-features
    install_cargo_crate cargo-unused-features unused-features

    # https://github.com/sharkdp/pastel
    install_cargo_crate pastel
  fi

  # Will add commands like: `cargo add`, `cargo rm` and `cargo upgrade`
  if [ ! -f "$PROVISION_CONFIG"/no-cargo-add ]; then
    if ! type "cargo-add" >/dev/null 2>&1; then
      cargo install cargo-edit
    fi
  fi

  provision_append_json ~/.vim/coc-settings.json '
"rust-analyzer.inlayHints.bindingModeHints.enable": false,
"rust-analyzer.inlayHints.chainingHints.enable": false,
"rust-analyzer.inlayHints.closingBraceHints.enable": false,
"rust-analyzer.inlayHints.closureReturnTypeHints.enable": "never",
"rust-analyzer.inlayHints.lifetimeElisionHints.enable": "never",
"rust-analyzer.inlayHints.parameterHints.enable": false,
"rust-analyzer.inlayHints.reborrowHints.enable": "never",
"rust-analyzer.inlayHints.typeHints.enable": false'
}

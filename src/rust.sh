#!/usr/bin/env bash

set -euo pipefail

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
  add_vscode_extension "rust-lang.rust-analyzer"

  install_nvim_package cespare/vim-toml
  install_nvim_package rust-lang/rust.vim

  cat >>~/.vimrc <<"EOF"
let g:rustfmt_autosave = 1

let RustPrintMapping="vnoremap <leader>kk yOprintln!(\"a {:?}\", a);<C-c>11hvpgvyf\"lllvp"
autocmd filetype rust :exe RustPrintMapping
EOF

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
}

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
  rust_provision_cleanup() {
    rm -rf ~/.rustup ~/.cargo
  }

  if [ -f "$PROVISION_CONFIG"/no-rust ]; then
    rust_provision_cleanup
    return
  elif [ "${IS_PROVISION_UPDATE:-0}" = "1" ]; then
    rust_provision_cleanup
  fi

  if [ ! -d ~/.rustup ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
    rustup install stable
    cargo install cargo-watch
  fi

  cat >>~/.shell_aliases <<"EOF"
RustBuildProvisionPackages() {
  mkdir -p ~/.local/bin
  while IFS= read -r -d '' FILE_PATH; do
    FILE_NAME=$(basename "$FILE_PATH")
    if [ ! -f "$FILE_PATH"/Cargo.toml ]; then
      continue
    fi
    if [ ! -f "$HOME/.local/bin/$FILE_NAME" ] || [ "$1" = "-f" ]; then
      (cd "$FILE_PATH" &&
        echo "" &&
        echo "Building: $FILE_NAME" &&
        cargo build --release --jobs 1 &&
        echo "Copying $FILE_NAME" &&
        cp target/release/"$FILE_NAME" "$HOME/.local/bin/" &&
        chmod +x "$HOME/.local/bin/$FILE_NAME" &&
        rm -rf target)
    fi
  done < <(find ~/development/environment/src/scripts/misc -maxdepth 1 -mindepth 1 -type d -print0)
}
_RustUpdateProvisionPackages() {
  rm -rf ~/.rustup
  rustup toolchain install stable
  while IFS= read -r -d '' FILE_PATH; do
    FILE_NAME=$(basename "$FILE_PATH")
    if [ ! -f "$FILE_PATH"/Cargo.toml ]; then
      continue
    fi
    (cd "$FILE_PATH" && \
      cargo update && \
      cargo build --release)
    printf "Updated: $FILE_NAME\n\n"
  done < <(find ~/development/environment/src/scripts/misc -maxdepth 1 -mindepth 1 -type d -print0)

  echo "Rebuilding all packages..."
  RustBuildProvisionPackages -f
  echo "Updated all packages, you should commit the changes"
}
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

  if [ "$IS_NIXOS" != "1" ]; then
    cat >>~/.shellrc <<"EOF"
if [ -d "$HOME"/.cargo/env ]; then
  . "$HOME/.cargo/env"
fi
export PASTEL_COLOR_MODE=24bit
EOF
  fi

  install_nvim_package fannheyward/coc-rust-analyzer

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

  if [ ! -f "$PROVISION_CONFIG"/nvim-lspconfig ]; then
    provision_append_json ~/.vim/coc-settings.json '
"rust-analyzer.cargo.features": "all",
"rust-analyzer.cargo.cfgs": [],
"rust-analyzer.inlayHints.bindingModeHints.enable": false,
"rust-analyzer.inlayHints.chainingHints.enable": false,
"rust-analyzer.inlayHints.closingBraceHints.enable": false,
"rust-analyzer.inlayHints.closureReturnTypeHints.enable": "never",
"rust-analyzer.inlayHints.lifetimeElisionHints.enable": "never",
"rust-analyzer.inlayHints.parameterHints.enable": false,
"rust-analyzer.inlayHints.reborrowHints.enable": "never",
"rust-analyzer.inlayHints.typeHints.enable": false'
  fi

  cat >>~/.shellrc <<"EOF"
if type rustup >/dev/null 2>&1; then
  rustup default 2>&1 >/dev/null || rustup default stable
fi
EOF
}

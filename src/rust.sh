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
_RustBuildProvisionPackages() {
  rustup toolchain install stable
  while IFS= read -r -d '' FILE_PATH; do
    FILE_NAME=$(basename "$FILE_PATH")
    if [ ! -f "$FILE_PATH"/Cargo.toml ]; then
      continue
    fi
    if [ ! -f "/usr/local/bin/environment_scripts/$FILE_NAME" ] || [ "$1" == "-f" ]; then
      (cd "$FILE_PATH" &&
        cargo build --release --jobs 1 && \
        sudo cp $HOME/.scripts/cargo_target/release/"$FILE_NAME" /usr/local/bin/environment_scripts/ && \
        sudo chmod +x /usr/local/bin/environment_scripts/"$FILE_NAME" && \
        sudo chown $USER /usr/local/bin/environment_scripts/"$FILE_NAME")
    fi
  done < <(find ~/development/environment/src/scripts/misc -maxdepth 1 -mindepth 1 -type d -print0)

  rm -rf ~/.scripts/cargo_target/release/deps
  rm -rf ~/.scripts/cargo_target/release/build
  rm -rf ~/.scripts/cargo_target/debug
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
  _RustBuildProvisionPackages -f
  echo "Updated all packages, you should commit the changes"
}
RustBuildProvisionPackages() { (nix develop ~/development/environment#rust \
  -c bash -c ". ~/.shellrc ; _RustBuildProvisionPackages $@"); }
RustUpdateProvisionPackages() { (nix develop ~/development/environment#rust \
  -c bash -c ". ~/.shellrc ; _RustUpdateProvisionPackages $@"); }
EOF

  mkdir -p ~/.cargo
  cat >~/.cargo/config.toml <<EOF
[build]
target-dir = "$HOME/.scripts/cargo_target"
EOF

  # This increases re-compilation times but these dirs can get very large
  rm -rf ~/.scripts/cargo_target/release/deps
  rm -rf ~/.scripts/cargo_target/release/build
  rm -rf ~/.scripts/cargo_target/debug

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
export PATH="/usr/local/bin/environment_scripts:$PATH"
export PASTEL_COLOR_MODE=24bit
EOF

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
"rust-analyzer.inlayHints.bindingModeHints.enable": false,
"rust-analyzer.inlayHints.chainingHints.enable": false,
"rust-analyzer.inlayHints.closingBraceHints.enable": false,
"rust-analyzer.inlayHints.closureReturnTypeHints.enable": "never",
"rust-analyzer.inlayHints.lifetimeElisionHints.enable": "never",
"rust-analyzer.inlayHints.parameterHints.enable": false,
"rust-analyzer.inlayHints.reborrowHints.enable": "never",
"rust-analyzer.inlayHints.typeHints.enable": false'
  fi
}

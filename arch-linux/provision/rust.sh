# rust START

if ! type rustc > /dev/null 2>&1 ; then
  curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y --default-toolchain nightly
  rustup component add rust-src
fi

cat >> ~/.bashrc <<"EOF"
export PATH=$PATH:~/.cargo/bin
export RUST_SRC_PATH=/home/igncp/.multirust/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src
EOF

cat >> ~/.bash_aliases <<"EOF"
alias CargoClippy='CMD="# rm -rf target && cargo clippy --all-targets --all-features -- -D warnings"; echo $CMD; history -s $CMD'
EOF

install_vim_package rust-lang/rust.vim
install_vim_package racer-rust/vim-racer
install_vim_package mattn/webapi-vim
install_vim_package cespare/vim-toml

cat >> ~/.vimrc <<"EOF"
let g:rustfmt_autosave = 1
let g:syntastic_rust_checkers = ['rustc']
" https://github.com/rust-lang/rust.vim/issues/130
  let g:syntastic_rust_rustc_args = '--'
  let g:syntastic_rust_rustc_exe = 'cargo check'
  let g:syntastic_rust_rustc_fname = ''

let g:racer_cmd = "/home/igncp/.cargo/bin/racer"
let g:racer_experimental_completer = 1

au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

let RustPrintMapping="vnoremap <leader>kk yOprintln!(\"a {:?}\", a);<C-c>11hvpgvyf\"lllvp"
autocmd filetype rust :exe RustPrintMapping

let g:deoplete#sources#rust#racer_binary='/home/igncp/.cargo/bin/racer'
let g:deoplete#sources#rust#rust_source_path='/home/igncp/rust-src'
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
install_cargo_crate racer

install_pacman_package valgrind

cat > ~/.vim-snippets/rust.snippets <<"EOF"
snippet xDeadCode
  #[allow(dead_code)]
snippet xNowInstant
  let ${0:now} = std::time::Instant::now();
snippet xPrintInstant
  println!("${1}{:?}", ${0:now}.elapsed());
snippet xModTests
  #[cfg(test)]
  mod tests {
    use super::*;

    ${0}
  }
EOF

# for code coverage
install_pacman_package llvm llvm-ar
install_from_aur lcov https://aur.archlinux.org/lcov.git

# rust END

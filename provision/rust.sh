# rust START

install_pacman_package rust rustc
install_pacman_package cargo

cat >> ~/.bashrc <<"EOF"
export PATH=$PATH:~/.cargo/bin
export RUST_SRC_PATH=/home/vagrant/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src
EOF

install_vim_package rust-lang/rust.vim
install_vim_package racer-rust/vim-racer
install_vim_package mattn/webapi-vim

cat >> ~/.vimrc <<"EOF"
let g:rustfmt_autosave = 1
let g:syntastic_rust_checkers = ['rustc']
" https://github.com/rust-lang/rust.vim/issues/130
  let g:syntastic_rust_rustc_args = '--'
  let g:syntastic_rust_rustc_exe = 'cargo check'
  let g:syntastic_rust_rustc_fname = ''

let g:racer_cmd = "/home/vagrant/.cargo/bin/racer"
let g:racer_experimental_completer = 1

au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)
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

if ! type rustup > /dev/null 2>&1 ; then
  curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y
  rustup component add rust-src
fi

install_pacman_package valgrind

# rust END

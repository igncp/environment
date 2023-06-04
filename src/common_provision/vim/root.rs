use crate::base::{system::System, Context};

pub fn run_vim_root(context: &mut Context) {
    // @TODO: Update first comment about provision.sh
    context.files.append(
        "/tmp/.root_vimrc",
        r###"
" This file was generated from ~/development/environment
syntax off
set number
filetype plugin indent on
let mapleader = "\<Space>"
set mouse-=a
vnoremap <Del> "_d
nnoremap <Del> "_d
nnoremap Q @q
nnoremap r gt
nnoremap R gT
"###,
    );

    context.write_file("/tmp/.root_vimrc", true);

    System::run_bash_command(
        r###"
ROOT_HOME=$(eval echo "~root")
sudo mv /tmp/.root_vimrc "$ROOT_HOME"/.vimrc
        "###,
    );
}

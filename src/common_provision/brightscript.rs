use crate::base::{config::Config, Context};

use super::vim::install_nvim_package;

pub fn setup_brightscript(context: &mut Context) {
    if !Config::has_config_file(&context.system, "brightscript") {
        return;
    }

    install_nvim_package(context, "vim-ruby/vim-ruby", None);

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
let g:NERDCustomDelimiters = { 'brs': { 'left': "'",'right': ''  }  }
au BufRead,BufNewFile *.brs set filetype=brs
au FileType brs set tabstop=4
au FileType brs set shiftwidth=4
au FileType brs set softtabstop=4
"###,
    );
}

pub use self::nvim::{add_special_vim_map, install_nvim_package, update_vim_colors_theme};
use self::{
    base::run_vim_base, clipboard_ssh::setup_clipboard_ssh, nvim::run_vim_nvim, root::run_vim_root,
};
use crate::base::Context;
pub use nvim::run_nvim_coc;

mod base;
mod clipboard_ssh;
mod nvim;
mod root;

pub fn run_vim(context: &mut Context) {
    run_vim_base(context);
    run_vim_root(context);
    run_vim_nvim(context);
    setup_clipboard_ssh(context);
}

use crate::base::Context;

pub use self::coc::run_nvim_coc;
pub use self::install::{add_special_vim_map, install_vim_package, update_vim_colors_theme};
use self::{base::run_nvim_base, textobj::run_nvim_textobj};

mod base;
mod coc;
mod install;
mod textobj;

pub fn run_vim_nvim(context: &mut Context) {
    run_nvim_base(context);
    run_nvim_textobj(context);
}

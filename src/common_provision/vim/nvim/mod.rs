use crate::base::Context;

pub use self::coc::run_nvim_coc;
pub use self::install::{
    add_special_vim_map, add_special_vim_map_re, install_nvim_package, update_vim_colors_theme,
};
use self::special_mappings::run_nvim_special_mappings;
use self::{base::run_nvim_base, textobj::run_nvim_textobj};

mod base;
mod coc;
mod install;
mod lua;
mod special_mappings;
mod textobj;

pub fn run_vim_nvim(context: &mut Context) {
    run_nvim_base(context);
    run_nvim_textobj(context);
    run_nvim_special_mappings(context);
}

use crate::{
    base::{config::Config, Context},
    common_provision::vim::install_nvim_package,
};

pub fn setup_hashi(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/hashi") {
        return;
    }

    install_nvim_package(context, "hashivim/vim-terraform", None); // https://github.com/hashivim/vim-terraform

    // Add logs: `export TF_LOG=1`
}

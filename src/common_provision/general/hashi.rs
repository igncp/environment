use crate::{
    base::{config::Config, system::System, Context},
    common_provision::vim::install_nvim_package,
};

pub fn setup_hashi(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/hashi") {
        return;
    }

    install_nvim_package(context, "hashivim/vim-terraform", None); // https://github.com/hashivim/vim-terraform

    // This was only tested in mac
    if !context.system.get_has_binary("terraform") && context.system.is_mac() {
        System::run_bash_command(
            r###"
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
"###,
        );
    }
}

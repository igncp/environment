use crate::base::{
    config::Config,
    system::{LinuxDistro, System},
    Context,
};

use super::vim::install_nvim_package;

fn install_ruby_gems(gems: &[&str]) {
    let installed_gems = System::get_bash_command_output("gem list");
    for gem in gems {
        if !installed_gems.contains(gem) {
            println!("Installing gem: {}", gem);
            System::run_bash_command(&format!("gem install {}", gem));
        }
    }
}

pub fn setup_ruby(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/ruby") {
        return;
    }

    if !context.system.get_has_binary("ruby") {
        if context.system.is_linux()
            && context.system.linux_distro.clone().unwrap() == LinuxDistro::Ubuntu
        {
            System::run_bash_command("sudo apt-get install -y libyaml-dev libssl-dev");
        }
    }

    install_ruby_gems(&["bundler", "lolcat", "fit-commit"]);

    install_nvim_package(context, "vim-ruby/vim-ruby", None); // https://github.com/vim-ruby/vim-ruby
}

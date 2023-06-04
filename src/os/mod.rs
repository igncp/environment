pub use self::install::setup_os_install;
use crate::base::{config::Config, system::LinuxDistro, Context};

mod arch;
mod disk_on_volume;
mod install;
mod mac;
mod ubuntu;

pub fn setup_os_beginnning(context: &mut Context) {
    if context.system.is_mac() {
        mac::run_mac_beginning(context);
    } else if context.system.is_linux() {
        let distro = context.system.linux_distro.clone().unwrap();

        match distro {
            LinuxDistro::Arch => arch::run_arch_beginning(context),
            LinuxDistro::Ubuntu => ubuntu::run_ubuntu_beginning(context),
            _ => panic!("Not implemented"),
        };
    }
}

pub fn setup_os_end(context: &mut Context) {
    if context.system.is_mac() {
        mac::run_mac_end(context);
    } else if context.system.is_linux() {
        if !Config::has_config_file(&context.system, "gui") {
            return;
        }

        let distro = context.system.linux_distro.clone().unwrap();

        match distro {
            LinuxDistro::Arch => arch::run_arch_gui(context),
            LinuxDistro::Ubuntu => ubuntu::run_ubuntu_gui(context),
            _ => panic!("Not implemented"),
        };
    }
}

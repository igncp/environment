pub use self::install::setup_os_install;
pub use self::multi_os_provision::{
    get_vim_multi_os_provision, get_vscode_keybindings_multi_os, get_vscode_settings_multi_os,
};
pub use self::windows::append_json_into_vs_code;
use crate::base::{config::Config, system::LinuxDistro, Context};

mod arch;
mod disk_on_volume;
mod install;
mod mac;
mod multi_os_provision;
mod nixos;
mod ubuntu;
mod windows;

pub fn setup_os_beginnning(context: &mut Context) {
    if context.system.is_windows() {
        windows::run_windows(context);
    } else if context.system.is_mac() {
        mac::run_mac_beginning(context);
    } else if context.system.is_linux() {
        let distro = context.system.linux_distro.clone().unwrap();

        match distro {
            LinuxDistro::Arch => arch::run_arch_beginning(context),
            LinuxDistro::Ubuntu | LinuxDistro::Debian => ubuntu::run_ubuntu_beginning(context),
            LinuxDistro::NixOS => nixos::run_nixos_beginning(context),
            _ => panic!("Not implemented"),
        };
    }
}

pub fn setup_os_end(context: &mut Context) {
    if context.system.is_mac() {
        mac::run_mac_end(context);
    } else if context.system.is_linux() {
        if !Config::has_config_file(&context.system, ".config/gui") {
            return;
        }

        let distro = context.system.linux_distro.clone().unwrap();

        match distro {
            LinuxDistro::Arch => arch::run_arch_gui(context),
            LinuxDistro::Ubuntu | LinuxDistro::Debian => ubuntu::run_ubuntu_gui(context),
            LinuxDistro::NixOS => {}
            _ => panic!("Not implemented"),
        };
    }
}

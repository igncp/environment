use crate::base::config::Config;
use crate::base::files::Files;
use crate::base::system::System;
use crate::base::Context;
#[cfg(target_family = "unix")]
use crate::common_provision::run_common_provision;
use crate::custom::run_custom;
use crate::os::{setup_os_beginnning, setup_os_end, setup_os_install};
#[cfg(target_family = "unix")]
use crate::top::run_top_setup;

mod base;
#[cfg(target_family = "unix")]
mod common_provision;
mod custom;
#[cfg(target_family = "unix")]
mod custom_template_unix;
#[cfg(target_family = "windows")]
mod custom_template_windows;
mod os;
#[cfg(target_family = "unix")]
mod top;

fn main() {
    let mut system = System::default();
    let files = Files::default();
    let config = Config::new(&system);

    system.is_nix_provision =
        system.is_nixos() || Config::has_config_file(&system, ".config/nix-only");

    let mut context = Context {
        config,
        files,
        system,
    };
    setup_os_install(&mut context);

    #[cfg(target_family = "unix")]
    run_top_setup(&mut context);

    setup_os_beginnning(&mut context);

    #[cfg(target_family = "unix")]
    run_common_provision(&mut context);

    setup_os_end(&mut context);

    run_custom(&mut context);

    context.write_files();

    println!("The provision finished successfully");
}

use crate::base::config::Config;
use crate::base::files::Files;
use crate::base::system::System;
use crate::base::Context;
use crate::common_provision::run_common_provision;
use crate::custom::run_custom;
use crate::os::{setup_os_beginnning, setup_os_end, setup_os_install};
use crate::top::run_top_setup;

mod base;
mod common_provision;
mod custom;
mod custom_template;
mod os;
mod top;

fn main() {
    let system = System::default();
    let files = Files::default();
    let config = Config::new(&system);

    let mut context = Context {
        config,
        files,
        system,
    };

    setup_os_install(&mut context);

    run_top_setup(&mut context);

    setup_os_beginnning(&mut context);

    run_common_provision(&mut context);

    setup_os_end(&mut context);

    run_custom(&mut context);

    context.write_files();

    println!("The provision finished successfully");
}

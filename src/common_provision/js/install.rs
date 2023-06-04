use std::{path::Path, process::Command};

use crate::base::{system::System, Context};

pub fn install_node_modules(context: &mut Context, names: Vec<&str>) {
    if context.system.node_version.is_none() {
        context.system.node_version = Some(
            String::from_utf8(
                Command::new("bash")
                    .arg("-c")
                    .arg("node --version | sed 's|^v||'")
                    .output()
                    .unwrap()
                    .stdout,
            )
            .unwrap()
            .trim()
            .to_string(),
        );
    }

    for module in names {
        let expected_module_path = format!(
            "{}/.asdf/installs/nodejs/{}/lib/node_modules/{}",
            context.system.home,
            context.system.node_version.as_ref().unwrap(),
            module
        );

        if !Path::new(&expected_module_path).exists() {
            println!("Installing node module: {}", module);
            System::run_bash_command(&format!(". $HOME/.asdf/asdf.sh ; npm i -g {module}"));
        }
    }
}

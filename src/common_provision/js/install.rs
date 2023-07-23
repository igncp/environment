use std::{path::Path, process::Command};

use crate::base::{system::System, Context};

pub fn install_node_modules(context: &mut Context, names: Vec<(&str, Option<&str>)>) {
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

    for (module, cmd) in names {
        if context.system.is_nix_provision {
            let cmd_check = cmd.unwrap_or(module);
            let expected_module_path =
                format!("{}/.npm-packages/bin/{}", context.system.home, cmd_check);

            if !Path::new(&expected_module_path).exists() {
                println!("Installing node module: {}", module);
                System::run_bash_command(&format!(r###"npm i -g {module}"###));
            }
        } else {
            let expected_module_path = format!(
                "{}/.asdf/installs/nodejs/{}/lib/node_modules/{}",
                context.system.home,
                context.system.node_version.as_ref().unwrap(),
                module
            );

            if !Path::new(&expected_module_path).exists() {
                println!("Installing node module: {}", module);
                System::run_bash_command(&format!(
                    r###"
. $HOME/.asdf/asdf.sh
npm i -g {module}
"###
                ));
            }
        };
    }
}

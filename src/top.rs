use std::{fs, path::Path, process};

use crate::base::{config::Config, system::System, Context};

#[link(name = "c")]
extern "C" {
    fn geteuid() -> u32;
}

pub fn run_top_setup(context: &mut Context) {
    let uid = unsafe { geteuid() };

    if uid == 0 {
        println!("You must not run the provision as root");
        process::exit(1);
    }

    if Path::new("/tmp/expected-vscode-extensions").exists() {
        fs::remove_file("/tmp/expected-vscode-extensions").unwrap_or(());
    }

    std::fs::create_dir_all(
        context
            .system
            .get_home_path("development/environment/project/.config"),
    )
    .unwrap();

    let config_theme_file = Config::get_config_file_path(&context.system, "theme");
    if !Path::new(&config_theme_file).exists() {
        System::run_bash_command(&format!("mkdir -p {config_theme_file}"));
        context.files.append(&config_theme_file, "dark");
        context.write_file(&config_theme_file, true);
    }

    std::fs::create_dir_all(context.system.get_home_path(".check-files")).unwrap();
    std::fs::create_dir_all(context.system.get_home_path(".scripts")).unwrap();

    if context.system.is_linux() {
        std::fs::create_dir_all(context.system.get_home_path(".config/systemd/user")).unwrap();
    }

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
ProvisionRustCompile() {
  (cd ~/development/environment/unix/scripts/misc/"$1" && cargo build --release)
}
ProvisionRustCompileAll() {
  for i in ~/development/environment/unix/scripts/misc/*; do
    if [ -d "$i" ]; then (cd "$i" && echo "$i" && cargo build --release); fi
  done
  for i in ~/development/environment/unix/scripts/toolbox/*; do
    if [ -d "$i" ]; then (cd "$i" && echo "$i" && cargo build --release); fi
  done
}
"###,
    );

    let cargo_target_path = context.system.get_home_path(".scripts/cargo_target");
    let cargo_config = format!(
        r###"
[build]
target-dir = "{cargo_target_path}"
"###
    );

    std::fs::create_dir_all(context.system.get_home_path(".cargo")).unwrap();
    context.files.append(
        &context.system.get_home_path(".cargo/config"),
        &cargo_config,
    );

    context.files.append(
        &context
            .system
            .get_home_path("development/environment/unix/.cargo/config"),
        &cargo_config,
    );

    if !context.system.get_has_binary("rustc") {
        System::run_bash_command(
            r###"
curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y --default-toolchain nightly
source "$HOME/.cargo/env"
rustup component add rust-src
cargo install cargo-edit
    "###,
        );
    }

    context.files.appendln(
        &context.system.get_home_path(".xinitrc"),
        "# This file was generated from environment provision",
    )
}

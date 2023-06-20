use crate::base::{config::Config, system::System, Context};

use super::vim::install_nvim_package;

pub fn setup_dart(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/dart") {
        return;
    }

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$PATH:$HOME/flutter/bin/cache/dart-sdk/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
"###,
    );

    install_nvim_package(context, "dart-lang/dart-vim-plugin", None);

    context.system.install_system_package("dart", None);

    if !context.system.get_has_binary("stagehand") {
        System::run_bash_command("pub global activate stagehand");
    }
}

use crate::base::{config::Config, Context};

use super::vim::install_nvim_package;

pub fn setup_kotlin(context: &mut Context) {
    if !Config::has_config_file(&context.system, "kotlin") {
        return;
    }

    context.system.install_system_package("kotlin", None);

    install_nvim_package(context, "udalov/kotlin-vim", None);

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias KotlinScript='kotlinc -script' # e.g. KotlinScript foo.kts
"###,
    );

    context.files.append(
        "/tmp/expected-vscode-extensions",
        r###"
fwcd.kotlin
mathiasfrohlich.Kotlin
esafirm.kotlin-formatter
"###,
    );
}

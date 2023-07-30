use crate::base::{config::Config, Context};

pub fn setup_shellcheck(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/shellcheck") {
        return;
    }

    context.system.install_system_package("shellcheck", None);

    let directives = [
        2016, 2028, 2046, 2059, 2086, 2088, 1117, 2143, 2148, 2164, 2181,
    ]
    .iter()
    .map(|num| {
        return format!("SC{num}");
    })
    .collect::<Vec<String>>()
    .join(",");

    context.home_append(
        ".shellrc",
        &format!("export SHELLCHECK_OPTS='-e {directives}'"),
    );
}

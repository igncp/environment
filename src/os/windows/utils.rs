use crate::base::Context;
use std::path::Path;

pub fn append_json_into_vs_code(context: &mut Context, path: &str, text: &str) {
    if Path::new("AppData\\Roaming\\Code - Insiders").exists() {
        context.files.append_json(
            &context
                .system
                .get_home_path(&format!("AppData\\Roaming\\Code - Insiders\\{}", path)),
            text,
        );
    }

    context.files.append_json(
        &context
            .system
            .get_home_path(&format!("AppData\\Roaming\\Code\\{}", path)),
        text,
    );
}

pub fn install_windows_package(context: &mut Context, package: &str, name: &str) {
    if !Path::new(&context.system.get_home_path(&format!(
        "AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\{}",
        name
    )))
    .exists()
        && !Path::new(&format!(
            "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\{}",
            name
        ))
        .exists()
    {
        context.system.install_system_package(package, None);
    }
}

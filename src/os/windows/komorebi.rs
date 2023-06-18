use std::path::Path;

use crate::base::{system::System, Context};

pub fn setup_komorebi(context: &mut Context) {
    context
        .system
        .install_system_package("LGUG2Z.komorebi", Some("komorebi.exe"));

    if !Path::new(&context.system.get_home_path("komorebic.lib.ahk")).exists() {
        System::run_bash_command("komorebic.exe ahk-library");
    }

    if !Path::new(&context.system.get_home_path("komorebi.generated.ahk")).exists() {
        System::run_bash_command("curl https://raw.githubusercontent.com/LGUG2Z/komorebi/master/komorebi.generated.ahk -o ~/komorebi.generated.ahk");
    }

    if !Path::new(&context.system.get_home_path("komorebi.ahk")).exists() {
        System::run_bash_command("curl https://raw.githubusercontent.com/LGUG2Z/komorebi/master/komorebi.sample.ahk -o ~/komorebi.ahk");
    }

    context.files.append(
        &context.system.get_home_path(".bash_profile"),
        r###"
alias KomorebiLog='code $LOCALAPPDATA/komorebi/komorebi.log'
"###,
    );

    /*
     * To complete after download:
     *
     * - Shortcuts for moving and changing to up to 5 workspaces
     * - No padding for all the named workspaces and containers
     * - Comment the import for generated
     *
     * The workflow for now should be:
     *
     * - First run komorebic start
     * - Then click ~/komorebic.ahk
     */
}

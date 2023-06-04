use crate::base::{system::System, Context};

pub fn run_python(context: &mut Context) {
    if context.system.is_linux() {
        context
            .system
            .install_system_package("python-pip", Some("pip"));
    } else if context.system.is_mac() && !context.system.get_has_binary("pip3") {
        System::run_bash_command(
            r###"
brew install python@3.8
"###,
        );
    }
}

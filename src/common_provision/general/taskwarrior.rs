use std::path::Path;

use crate::base::{system::System, Context};

pub fn setup_taskwarrior(context: &mut Context) {
    context
        .system
        .install_system_package("taskwarrior", Some("task"));
    let task_file = context.system.get_home_path(".taskrc");

    context.files.append(
        &task_file,
        r###"
# This file is generated from ~/development/environment
# Use the command 'task show' to see all defaults and overrides
data.location=~/.task
alias.d=done
alias.a=add
"###,
    );

    if context.system.is_linux() {
        if Path::new("/usr/share/taskwarrior/no-color.theme").exists() {
            context
                .files
                .appendln(&task_file, "include /usr/share/taskwarrior/no-color.theme");
        } else if Path::new("/usr/share/doc/task/rc/no-color.theme").exists() {
            context
                .files
                .appendln(&task_file, "include /usr/share/doc/task/rc/no-color.theme");
        }
    } else if context.system.is_mac() {
        let theme_path = System::get_bash_command_output(
            r#"find /opt/homebrew/Cellar/task -type f -name "no-color.theme" "#,
        );
        context
            .files
            .appendln(&task_file, &format!("include {theme_path}"));
    }

    context.files.append(
        &context.system.get_home_path(".zshrc"),
        r###"
source "$HOME"/.oh-my-zsh/plugins/taskwarrior/taskwarrior.plugin.zsh
"###,
    );
}

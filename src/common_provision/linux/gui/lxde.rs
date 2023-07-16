use std::path::Path;

use crate::base::{config::Config, system::System, Context};

pub fn setup_lxde(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/gui-lxde") {
        return;
    }

    context
        .system
        .install_system_package("lxde", Some("startlxde"));

    context
        .files
        .appendln(&context.system.get_home_path(".xinitrc"), "exec startlxde");

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias LXDEReload='echo "Remember to run in guest"; openbox-lxde --reconfigure'
alias LXDEPanelRestart='DISPLAY=:0 lxpanelctl restart'
alias LXDEPanelConfig='nvim ~/.config/lxpanel/LXDE/panels/panel && DISPLAY=:0 lxpanelctl restart'
"###,
    );

    if Path::new(
        &context
            .system
            .get_home_path(".config/pcmanfm/LXDE/pcmanfm.conf"),
    )
    .exists()
    {
        System::run_bash_command(
            r###"
sed -i 's|maximized=.*|maximized=1|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
sed -i 's|show_hidden=.*|show_hidden=1|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
sed -i 's|view_mode=.*|view_mode=list|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
"###,
        );
    }

    // Things to automate:
    // - Change the background color and fontsize of the panel below

    if Path::new(
        &context
            .system
            .get_home_path(".config/lxpanel/LXDE/panels/panel"),
    )
    .exists()
    {
        System::run_bash_command(
            r###"
sed -i 's|autohide=.*|autohide=1|' ~/.config/lxpanel/LXDE/panels/panel
"###,
        );
    }

    // To add a new custom application launcher (either in the menu or in the panel):
    // - Copy a file in /usr/share/applications/*.desktop and adapt it
    // - If it is a script, set `Terminal=true` in the .desktop file
    // - Don't forget to have the same ownership and permissions as the other files
    // - Copy `/usr/bin/lxterminal` into `/usr/bin/lxterminal` (with the same ownership and permissions)
    // - To refresh: `killall lxpanel ; lxpanel --profile LXDE ; find ~/.cache/menus -name '*' -type f -print0 | xargs -0 rm ; lxpanel -p LXDE &`
}

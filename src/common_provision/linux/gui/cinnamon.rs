use crate::base::{config::Config, Context};

pub fn setup_cinnamon(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/gui-cinnamon") {
        return;
    }

    context.home_append(
        ".shell_aliases",
        r###"
CinnamonShortcutsDump() {
    dconf dump /org/cinnamon/desktop/keybindings/ > /tmp/dconf-settings.conf
    echo "Dumped to /tmp/dconf-settings.conf"
}

CinnamonShortcutsLoad() {
    dconf load /org/cinnamon/desktop/keybindings/ < /tmp/dconf-settings.conf
    echo "Loaded /tmp/dconf-settings.conf"
}
"###,
    );
}

#!/usr/bin/env bash

set -euo pipefail

setup_gui_lxde() {
  if [ ! -f "$PROVISION_CONFIG"/gui-lxde ]; then
    return
  fi

  if [ "$IS_DEBIAN" != "1" ]; then
    return
  fi

  install_system_package_os lxde startlxde
}

#     if !context.system.is_nixos() {
#         System::run_bash_command(
#             r###"
# cat > ~/i3lock.service <<"EOF"
# [Unit]
# Description=Lock screen before suspend
# Before=sleep.target

# [Service]
# User=_USER_
# Type=forking
# Environment=DISPLAY=:0
# ExecStart=/usr/bin/i3lock -c 000000

# [Install]
# WantedBy=sleep.target
# EOF
# sed -i "s|_USER_|$USER|g" ~/i3lock.service
# sudo mv ~/i3lock.service /etc/systemd/system/
# sudo systemctl enable --now i3lock.service
# "###,
#         );
#     }

#     // picom: can be disabled due performance
#     if !Config::has_config_file(&context.system, ) {
#         context.system.install_system_package("picom", None);
#         System::run_bash_command(
#             r###"
# cp ~/development/environment/src/config-files/picom.conf ~/.config/picom.conf
# echo 'exec --no-startup-id picom' >> ~/.config/i3/config # remove this line to disable if performance slow
# echo "alias PicomModify='$EDITOR ~/project/provision/picom.conf && cp ~/project/provision/picom.conf ~/.config/picom.conf'" >> ~/.shell_aliases
# "###,
#         );
#     }
# }
# use std::path::Path;

# use crate::base::{config::Config, system::System, Context};

# pub fn setup_lxde(context: &mut Context) {
#     if !Config::has_config_file(&context.system, ".config/gui-lxde") {
#         return;
#     }

#     context
#         .system
#         .install_system_package("lxde", Some("startlxde"));

#     context
#         .files
#         .appendln(&context.system.get_home_path(".xinitrc"), "exec startlxde");

#     context.files.append(
#         &context.system.get_home_path(".shell_aliases"),
#         r###"
# alias LXDEReload='echo "Remember to run in guest"; openbox-lxde --reconfigure'
# alias LXDEPanelRestart='DISPLAY=:0 lxpanelctl restart'
# alias LXDEPanelConfig='nvim ~/.config/lxpanel/LXDE/panels/panel && DISPLAY=:0 lxpanelctl restart'
# "###,
#     );

#     if Path::new(
#         &context
#             .system
#             .get_home_path(".config/pcmanfm/LXDE/pcmanfm.conf"),
#     )
#     .exists()
#     {
#         System::run_bash_command(
#             r###"
# sed -i 's|maximized=.*|maximized=1|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
# sed -i 's|show_hidden=.*|show_hidden=1|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
# sed -i 's|view_mode=.*|view_mode=list|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
# "###,
#         );
#     }

#     // Things to automate:
#     // - Change the background color and fontsize of the panel below

#     if Path::new(
#         &context
#             .system
#             .get_home_path(".config/lxpanel/LXDE/panels/panel"),
#     )
#     .exists()
#     {
#         System::run_bash_command(
#             r###"
# sed -i 's|autohide=.*|autohide=1|' ~/.config/lxpanel/LXDE/panels/panel
# "###,
#         );
#     }

#     // To add a new custom application launcher (either in the menu or in the panel):
#     // - Copy a file in /usr/share/applications/*.desktop and adapt it
#     // - If it is a script, set `Terminal=true` in the .desktop file
#     // - Don't forget to have the same ownership and permissions as the other files
#     // - Copy `/usr/bin/lxterminal` into `/usr/bin/lxterminal` (with the same ownership and permissions)
#     // - To refresh: `killall lxpanel ; lxpanel --profile LXDE ; find ~/.cache/menus -name '*' -type f -print0 | xargs -0 rm ; lxpanel -p LXDE &`
# }

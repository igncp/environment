# use crate::base::{config::Config, system::System, Context};

# pub fn setup_i3(context: &mut Context) {
#     if !Config::has_config_file(&context.system, ".config/gui-i3") {
#         return;
#     }

#     // To start it: startx
#     if !context.system.get_has_binary("i3") {
#         if Config::has_config_file(&context.system, ".config/standard-i3") {
#             context.system.install_system_package("i3", None);
#         } else {
#             context.system.install_system_package("i3-gaps", Some("i3"));
#         }
#     }

#     context.system.install_system_package("i3lock", None);
#     context.system.install_system_package("blocks", None);

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

#     context.home_appendln(".xinitrc", r#"sh ~/.keyboard-config.sh"#);
#     if !Config::has_config_file(&context.system, ".config/no-auto-i3") {
#         context.home_appendln(".xinitrc", r#"exec i3"#);
#     }

#     context.home_append(
#         ".shell_aliases",
#         r###"
# I3VMSetup() {
#   /usr/bin/VBoxClient-all;
#   # Run `xrandr` to see the available outputs and modes:
#     # xrandr --output Virtual-1 --mode 1280x768
# }
# alias I3GBLayout='setxkbmap -layout gb'
# alias I3Reload='i3-msg reload'
# alias I3LogOut='i3-msg exit'
# alias I3DetectAppClass="xprop | grep WM_CLASS"
# alias I3DetectAppName="xprop | grep WM_NAME"
# alias I3Poweroff='systemctl poweroff'
# alias I3Start='startx'
# I3Configure() {
#   $EDITOR -p ~/project/provision/i3-config ~/project/provision/i3blocks.sh
#   provision.sh
# }
# "###,
#     );

#     System::run_bash_command(
#         r#"
# mkdir -p ~/.config/i3
# cp ~/development/environment/unix/config-files/i3-config ~/.config/i3/config
# bash $HOME/development/environment/unix/config-files/i3blocks.sh
# "#,
#     );

#     // picom: can be disabled due performance
#     if !Config::has_config_file(&context.system, ".config/without-picom") {
#         context.system.install_system_package("picom", None);
#         System::run_bash_command(
#             r###"
# cp ~/development/environment/unix/config-files/picom.conf ~/.config/picom.conf
# echo 'exec --no-startup-id picom' >> ~/.config/i3/config # remove this line to disable if performance slow
# echo "alias PicomModify='$EDITOR ~/project/provision/picom.conf && cp ~/project/provision/picom.conf ~/.config/picom.conf'" >> ~/.shell_aliases
# "###,
#         );
#     }
# }

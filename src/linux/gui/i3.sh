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
#     if !Config::has_config_file(&context.system, ".config/without-picom") {
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

#     if !Path::new(&context.system.get_home_path(".check-files/oomd")).exists()
#         && !context.system.is_nix_provision
#     {
#         System::run_bash_command(
#             r###"
# if [ -n "$(systemctl list-units --full -all | grep systemd-oomd)" ]; then
#     sudo systemctl enable --now systemd-oomd
# fi
# touch ~/.check-files/oomd
# "###,
#         );
#     }

#     if Config::has_config_file(&context.system, ".config/netdata") {
#         context.system.install_system_package("netdata", None);
#         if !Path::new(&context.system.get_home_path(".check-files/netdata")).exists() {
#             System::run_bash_command(
#                 r###"
# sudo systemctl enable --now netdata
# touch ~/.check-files/netdata
# "###,
#             );
#         }
#     }

#     // https://wiki.archlinux.org/title/Google_Authenticator
#     if Config::has_config_file(&context.system, ".config/gauth-pam") {
#         context
#             .system
#             .install_system_package("libpam-google-authenticator", Some("google-authenticator"));
#         // - `/etc/pam.d/sshd`: `auth required pam_google_authenticator.so`
#         // - `/etc/ssh/sshd_config`: `KbdInteractiveAuthentication yes`
#         // - `/etc/ssh/sshd_config`: `AuthenticationMethods keyboard-interactive:pam,publickey`
#     }

#     if context.system.get_has_binary("crond") {
#         System::run_bash_command(
#             r###"
# sudo touch /var/spool/cron/"$USER"
# sudo touch /var/spool/cron/root
# sudo chown "$USER" /var/spool/cron/"$USER"
# printf '' > /var/spool/cron/"$USER"
# sudo sh -c "printf '' > /var/spool/cron/root"

# # /etc/motd is read by /etc/pam.d/system-login
# sudo sh -c "echo '*/10 * * * * sh /home/$USER/.scripts/motd_update.sh' >> /var/spool/cron/root"
# sudo touch /etc/motd
# sudo chmod o+r /etc/motd
# "###,
#         );

#         // @TODO: setup alias for this
#         // echo '- swap: https://wiki.archlinux.org/index.php/swap'
#         // echo '    sudo su # can create the swapfile inside the home directory if bigger volume'
#         // echo '    dd if=/dev/zero of=/swapfile bs=1G count=10 status=progress # RAM size + 2G, in this case 10 GB Swap'
#         // echo "    chmod 600 /swapfile ; mkswap /swapfile ; swapon /swapfile ; echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab"

#         // @TODO: Check if it is Ubuntu to do this
#         // crontab /var/spool/cron/"$USER"
#         // sudo crontab /var/spool/cron/root
#     }

#     if Config::has_config_file(&context.system, ".config/usb-modem") {
#         context
#             .system
#             .install_system_package("modemmanager", Some("ModemManager"));
#         context
#             .system
#             .install_system_package("usb_modeswitch", None);
#         context
#             .system
#             .install_system_package("nm-connection-editor", None);
#         context.system.install_system_package("wvdial", None);
#         context
#             .system
#             .install_system_package("libmbim", Some("mbimcli"));

#         context.files.append(
#             &context.system.get_home_path(".shell_aliases"),
#             r###"
# alias USBModemManagerStart='sudo systemctl start ModemManager'
# alias USBModemManagerList='sudo mmcli --list-modems'
# alias USBModemShowModem0='sudo mmcli --modem=/org/freedesktop/ModemManager1/Modem/0' # from USBModemManagerList
# USBModemSetPin() { sudo mmcli --sim=/org/freedesktop/ModemManager1/SIM/0 --pin="$1"; }
# "###,
#         );
#     }

#     setup_gui(context);
# }

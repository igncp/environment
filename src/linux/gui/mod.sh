# pub fn setup_gui(context: &mut Context) {
#     // This setup requires that the user is already logged in in the main console
#     // Use SSH tunneling from the client and don't open the port:
#     //   `ssh -fN -L 5900:localhost:5900 REMOTE_ADDRESS`
#     if Config::has_config_file(&context.system, ".config/x11-vnc-server") {
#         context.system.install_system_package("x11vnc", None);

#         context.files.append(
#             &context.system.get_home_path(".shell_aliases"),
#             r###"
# XVNCServerStart() {
#   if [ ! -f ~/development/environment/project/.config/vnc-xrandr-output ]; then echo "~/development/environment/project/.config/vnc-xrandr-output missing"; return 1; fi
#   if [ ! -f ~/development/environment/project/.config/vnc-xrandr-mode ]; then echo "~/development/environment/project/.config/vnc-xrandr-mode missing"; return 1; fi
#   if [ ! -f ~/development/environment/project/.config/vnc-port ]; then echo "~/development/environment/project/.config/vnc-port missing"; return 1; fi
#   systemctl start --user x11vnc.service
#   sleep 1
#   DISPLAY=:0.0 xrandr --output "$(cat ~/development/environment/project/.config/vnc-xrandr-output)" --mode "$(cat ~/development/environment/project/.config/vnc-xrandr-mode)"
# }
# XVNCServerStorePassword() { x11vnc -storepasswd; }

# # This server (from tigervnc) opens new sessions, so the operations are not
# # displayed in the physical device. It can be configured whithin lightdm:
# # /etc/lightdm/lightdm.conf

# # This server doesn't share the main X11 session
# # To run, for example in display `:3`: vncserver :3 &
# alias VNCServerPassword='vncpasswd'
# "###,
#         );

#         // Don't enable, just manually start or stop
#         // Until reboot, have to: `systemctl --user daemon-reload`
#         context.home_append(
#             ".config/systemd/user/x11vnc.service",
#             r###"
# [Unit]
# Description=VNC Server for X11

# [Service]
# ExecStart=/usr/bin/bash -c 'x11vnc -usepw -rfbport $(cat /home/igncp/development/environment/project/.config/vnc-port) -shared'
# ExecStop=/usr/bin/x11vnc -R stop
# Restart=always
# RestartSec=2

# [Install]
# WantedBy=multi-user.target
# "###
# );
#     }

#     if !context.system.is_nix_provision {
#         System::run_bash_command(
#             r###"
# if [ -z "$(groups | grep video || true)" ]; then
#   sudo usermod -a -G video "$USER"
#   sudo usermod -a -G audio "$USER"
# fi
# "###,
#         );
#     }

#     if !context.system.is_debian() {
#         context.system.install_system_package("acpi", None);
#     }

#     // Bluetooth
#     // For dual boot:
#     // - Copy the key in /var/lib/bluetooth/MAC/DEVICE_MAC/info
#     // - If the other OS is Windows, use PSExec64 to extract it into a .reg
#     //   file, then remove the commas and convert to upper case
#     // https://wiki.archlinux.org/title/bluetooth#For_Windows
#     // - Power off the device after pairing with the 1st OS, copy it in the 2nd,
#     //   reboot (without reboot, it didn't work), and only then power on device

#     let set_background_path = context.system.get_home_path(".scripts/set-background.sh");
#     context.files.append(
#         &set_background_path,
#         r###"
# feh --bg-fill "$1"
# cat ~/.fehbg | grep --color=never -o '\/home\/.*jpg' | sed 's|^|Image: |'
# "###,
#     );
#     let variety_dir = context.system.get_home_path(".config/variety/Downloaded");
#     let wallpaper_update_path = context.system.get_home_path(".scripts/wallpaper_update.sh");
#     context.files.append(
#         &wallpaper_update_path,
#         &format!(
#             r###"
# if [ -d {variety_dir} ]; then
#   find {variety_dir} -type f -name *.jpg | shuf -n 1 | xargs -I {{}} sh ~/.set-background.sh {{}}
# fi
# "###
#         ),
#     );

#     [set_background_path, wallpaper_update_path]
#         .iter()
#         .for_each(|file_path| {
#             context.write_file(file_path, true);
#             let perm = Permissions::from_mode(0o700);
#             set_permissions(file_path, perm).unwrap();
#         });

#     context.home_append(
#         ".shell_aliases",
#         &format!(
#             r###"
# alias WallpaperPrintCurrent="cat ~/.fehbg | grep --color=never -o '\/home\/.*jpg'"

# alias KeyboardLayoutGB='setxkbmap -layout gb'
# alias KeyboardLayoutUS='setxkbmap -layout us'
# alias KeyboardLayoutES='setxkbmap -layout es' # accents work when also enabling ibus
# alias KeyboardQuery='setxkbmap -query'
# alias KeyboardListKeys='xmodmap -pke'
# alias KeyboardRefreshConfig='sh ~/.keyboard-config.sh'

# alias XKBCompDump='xkbcomp $DISPLAY /tmp/xkb-config.xkb'
# alias XKBCompLoad='xkbcomp /tmp/xkb-config.xkb $DISPLAY'
# "###
#         ),
#     );

#     if Config::has_config_file(&context.system, ".config/gui-virtualbox")
#         && !context.system.is_nixos()
#     {
#         context.system.install_system_package("virtualbox", None);

#         if !Path::new(&context.system.get_home_path(".check-files/virtualbox")).exists() {
#             if context.system.is_arch() {
#                 context
#                     .system
#                     .install_system_package("virtualbox-host-modules-arch", None);
#             }

#             System::run_bash_command(
#                 r###"
# sudo usermod -a -G vboxusers "$USER"
# touch ~/.check-files/virtualbox
# "###,
#             );
#         }

#         if !Path::new(
#             &context
#                 .system
#                 .get_home_path(".local/share/applications/virtualbox-dark.desktop"),
#         )
#         .exists()
#         {
#             println!("Copy `.local/share/applications/virtualbox.desktop` into `.local/share/applications/virtualbox-dark.desktop`");
#             println!("and update the command into: `virtualbox --style FusionDark %U`");
#         }
#     }

#     setup_lxde(context);
#     setup_i3(context);
#     setup_vscode(context);
#     setup_rime(context);
#     setup_copyq(context);
#     setup_cinnamon(context);
# }

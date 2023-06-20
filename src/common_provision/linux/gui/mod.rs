use std::path::Path;

use crate::base::{config::Config, system::System, Context};

use self::{lxde::setup_lxde, vscode::setup_vscode};

mod lxde;
mod vscode;

pub fn setup_gui(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/gui") {
        return;
    }

    if !Path::new(&context.system.get_home_path(".check-files/gui")).exists() {
        println!("Installing Xorg");
        context.system.install_system_package("xorg", None);
        context
            .system
            .install_system_package("xorg-init", Some("startx"));

        System::run_bash_command("touch ~/.check-files/gui");
    }

    context.system.install_system_package("xclip", None);
    context.system.install_system_package("arandr", None);

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias XClipCopy='xclip -selection clipboard' # usage: echo foo | XClipCopy
alias XClipPaste='xclip -selection clipboard -o'
"###,
    );

    context
        .system
        .install_system_package("tigervnc", Some("vncserver")); // VNC client and server

    // This setup requires that the user is already logged in in the main console
    // Use SSH tunneling from the client and don't open the port:
    //   `ssh -fN -L 5900:localhost:5900 REMOTE_ADDRESS`
    if Config::has_config_file(&context.system, ".config/x11-vnc-server") {
        context.system.install_system_package("x11vnc", None);

        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
XVNCServerStart() {
  if [ ! -f ~/development/environment/project/.config/vnc-xrandr-output ]; then echo "~/development/environment/project/.config/vnc-xrandr-output missing"; return 1; fi
  if [ ! -f ~/development/environment/project/.config/vnc-xrandr-mode ]; then echo "~/development/environment/project/.config/vnc-xrandr-mode missing"; return 1; fi
  if [ ! -f ~/development/environment/project/.config/vnc-port ]; then echo "~/development/environment/project/.config/vnc-port missing"; return 1; fi
  systemctl start --user x11vnc.service
  sleep 1
  DISPLAY=:0.0 xrandr --output "$(cat ~/development/environment/project/.config/vnc-xrandr-output)" --mode "$(cat ~/development/environment/project/.config/vnc-xrandr-mode)"
}
XVNCServerStorePassword() { x11vnc -storepasswd; }

# This server (from tigervnc) opens new sessions, so the operations are not
# displayed in the physical device. It can be configured whithin lightdm:
# /etc/lightdm/lightdm.conf

# This server doesn't share the main X11 session
# To run, for example in display `:3`: vncserver :3 &
alias VNCServerPassword='vncpasswd'
"###,
        );

        // Don't enable, just manually start or stop
        // Until reboot, have to: `systemctl --user daemon-reload`
        context.files.append(
            &context.system.get_home_path(".config/systemd/user/x11vnc.service"),
            r###"
[Unit]
Description=VNC Server for X11

[Service]
ExecStart=/usr/bin/bash -c 'x11vnc -usepw -rfbport $(cat /home/igncp/development/environment/project/.config/vnc-port) -shared'
ExecStop=/usr/bin/x11vnc -R stop
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
"###
);
    }

    System::run_bash_command(
        r###"
if [ -z "$(groups | grep video || true)" ]; then
  sudo usermod -a -G video "$USER"
  sudo usermod -a -G audio "$USER"
fi
"###,
    );

    context.system.install_system_package("acpi", None);

    setup_lxde(context);
    setup_vscode(context);
}

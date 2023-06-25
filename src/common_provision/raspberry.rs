use std::path::Path;

use crate::base::{config::Config, system::System, Context};

pub fn setup_raspberry(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/raspberry") {
        return;
    }

    // To setup Wifi in Ubuntu
    //   sudo apt-get install -y network-manager ; nmtui
    //   Or setup: /etc/netplan/50-cloud-init.yaml
    //   network:
    //       ethernets:
    //           eth0:
    //               dhcp4: true
    //               optional: true
    //       wifis:
    //           wlan0:
    //               dhcp4: true
    //               optional: true
    //               access-points:
    //                   WIFI_NAME:
    //                       password: WIFI_PASS
    //       version: 2

    context.system.install_system_package("raspi-config", None);

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
# From libraspberrypi-bin
alias RaspberryTemp='vcgencmd measure_temp'
"###,
    );

    // Enable VNC: https://www.pitunnel.com/doc/access-vnc-remote-desktop-raspberry-pi-over-internet

    if context.system.is_ubuntu()
        && !Path::new(&context.system.get_home_path(".check-files/raspi-tools")).exists()
    {
        System::run_bash_command(
            r###"
sudo apt install -y linux-tools-raspi
touch ~/.check-files/raspi-tools
"###,
        );
    }

    // https://retropie.org.uk/docs/Nintendo-Switch-Controllers/
}

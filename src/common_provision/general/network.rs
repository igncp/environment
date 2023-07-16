use crate::base::{
    config::Config,
    system::{LinuxDistro, System, OS},
    Context,
};

// https://wiki.archlinux.org/title/wireshark
// https://docs.mitmproxy.org/stable/overview-installation/
// - Local instance: http://mitm.it/

pub fn setup_network(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/network-analysis") {
        return;
    }

    if !context.system.get_has_binary("wireshark") {
        match context.system.os {
            OS::Linux => {
                let distro = context.system.linux_distro.clone().unwrap();

                match distro {
                    LinuxDistro::Ubuntu | LinuxDistro::Debian => {
                        System::run_bash_command(
                            r###"
sudo add-apt-repository ppa:wireshark-dev/stable -y
sudo apt-get update
sudo apt-get install wireshark tshark -y
sudo adduser $USER wireshark
"###,
                        );
                    }
                    LinuxDistro::Arch => {
                        context
                            .system
                            .install_system_package("wireshark-cli", Some("tshark"));
                    }
                    _ => {}
                }
            }
            OS::Mac => {
                System::run_bash_command(r#"brew install --cask wireshark"#);
            }
            _ => {}
        }
    }

    context.system.install_with_nix("mitmproxy", None);
}

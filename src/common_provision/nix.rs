use crate::base::{config::Config, system::System, Context};

pub fn setup_nix(context: &mut Context) {
    if !context.system.get_has_binary("nix") {
        if context.system.is_mac() {
            System::run_bash_command(
                r###"
sh <(curl -L https://nixos.org/nix/install)
"###,
            );
        } else {
            System::run_bash_command(
                r###"
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
sh <(curl -L https://nixos.org/nix/install) --daemon
"###,
            );
        }
    }

    if Config::has_config_file(&context.system, ".config/nix-only")
        && !context.system.get_has_binary("home-manager")
    {
        println!("You need to install home-manager packages");
        println!("Run: `nix-shell -p home-manager` and then `SwitchHomeManager`");
        std::process::exit(1);
    }
}

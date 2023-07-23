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
curl https://nixos.org/nix/install | sh
"###,
            );
        }
    }

    if !context.system.is_nixos() {
        context.home_appendln(
            ".shellrc",
            r###"
if [ -d "$HOME/.nix-profile/etc/profile.d" ]; then
    .shellrc", r#". ~/.nix-profile/etc/profile.d/nix.sh
fi
"###,
        );
    }

    context.home_append(
        ".shell_aliases",
        r###"

alias NixClearSpace='nix-collect-garbage'
alias NixInstallPackage='nix-env -iA'
alias NixListChannels='nix-channel —-list'
alias NixListGenerations="nix-env --list-generations"
alias NixListPackages='nix-env --query "*"'
alias NixListReferrers='nix-store --query --referrers' # Add the full path of the store item
alias NixRemovePackage='nix-env -e'
alias NixUpdate='nix-env -u && nix-channel --update && nix-env -u'

NixFormat() {
    if [ -n "$1" ]; then
        alejandra $@
        return
    fi
    alejandra ./**/*.nix
}
"###,
    );

    if Config::has_config_file(&context.system, ".config/nix-only") {
        context.home_append(
            ".bashrc",
            r###"
NixDevelopEnvironment() {
    if [ -z "$CD_INTO_NIX" ]; then
        cd ~/development/environment/nixos/nix-only
        CD_INTO_NIX=1 nix develop path:$(pwd)
    fi
}

NixDevelopEnvironment
"###,
        );
    }
}

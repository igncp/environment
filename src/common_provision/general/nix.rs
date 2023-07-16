use crate::base::{system::System, Context};

pub fn setup_nix(context: &mut Context) {
    if !context.system.get_has_binary("nix") {
        System::run_bash_command(
            r###"
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf || true
curl https://nixos.org/nix/install | sh
"###,
        );
    }

    if !context.system.is_nixos() {
        context.home_appendln(
            ".shellrc",
            r#". /home/igncp/.nix-profile/etc/profile.d/nix.sh"#,
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
alias NixRemovePackage='nix-env -e'
alias NixUpdate='nix-env -u && nix-channel --update && nix-env -u'

"###,
    );
}

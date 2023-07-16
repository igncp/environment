use crate::base::{system::System, Context};

pub fn run_nixos_beginning(context: &mut Context) {
    context.home_append(
        ".shell_aliases",
        r###"
alias NixOsProfileHistory='nix profile history --profile /nix/var/nix/profiles/system'

ConfigNixOsProvisionList() {
    if [ -n "$1" ]; then
        ~/.scripts/cargo_target/release/provision_choose_config "$1"
        return
    fi
    ~/.scripts/cargo_target/release/provision_choose_config && RebuildNixOs && Provision
}

alias NixDevelopPath='nix develop path:$(pwd)' # Also possible to just run a command: `NixDevelopPath -c cargo build`

NixFormat() {
    if [ -n "$1" ]; then
        alejandra $@
        return
    fi
    alejandra ./**/*.nix
}

# Different prefix due to being a common command
RebuildNixOs() {
    (cd ~/development/environment/nixos && \
    sudo nixos-rebuild --show-trace switch -I nixos-config=$(pwd)/configuration.nix)
}
"###,
    );

    context.home_append(
        ".npmrc",
        r###"
prefix = ${HOME}/.npm-packages
"###,
    );

    context.home_append(
        ".zshrc",
        r###"
eval "$(direnv hook zsh)"
"###,
    );

    System::run_bash_command(
        r###"
echo 'umask 0077' > /tmp/profile.local

sudo mv /tmp/profile.local /etc/profile.local
"###,
    );
}

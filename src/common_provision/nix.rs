use std::path::Path;

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

    if !Path::new(&context.system.get_home_path(".pip")).exists() {
        System::run_bash_command(
            r###"
mkdir -p ~/.pip
"###,
        )
    }

    context.home_appendln(
        ".shellrc",
        r###"
export PIP_PREFIX=$HOME/.pip
export PYTHONPATH=$(echo $HOME/.pip/lib/*/site-packages | tr " " ":")
export PATH="$HOME/.pip/bin:$PATH"
"###,
    );

    if !context.system.is_nixos() {
        context.home_appendln(
            ".shellrc",
            r###"
if [ -f "~/.nix-profile/etc/profile.d/nix.sh" ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
fi

if [ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
    . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
fi
"###,
        );
    }

    std::fs::create_dir_all(context.system.get_home_path(".config/nix")).unwrap();

    context.home_append(
        ".config/nix/nix.conf",
        r###"
experimental-features = nix-command flakes
"###,
    );

    context.home_append(
        ".zshrc",
        r###"
eval "$(direnv hook zsh)"
"###,
    );

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
alias NixEvalFile='nix-instantiate --eval'

alias NixDevelop='NIX_SHELL_LEVEL=1 nix develop -c zsh'
alias NixDevelopPath='NIX_SHELL_LEVEL=1 nix develop path:$(pwd) -c zsh'
alias NixDevelopBase='NIX_SHELL_LEVEL=1 nix develop'
alias NixDevelopBasePath='NIX_SHELL_LEVEL=1 nix develop path:$(pwd)'

alias HomeManagerInitFlake='nix run home-manager/release-23.05 -- init'
alias HomeManagerDeleteGenerations='home-manager expire-generations "-1 second"'

alias SudoNix='sudo --preserve-env=PATH env'

SwitchHomeManager() {
    # Impure is needed for now to read the config
    home-manager switch --impure --flake ~/development/environment/nixos/home-manager
}

# # To patch a binary interpreter path, for example for 'foo:
# patchelf --set-interpreter /usr/lib64/ld-linux-aarch64.so.1 ./foo
# # To read the current interpreter:
# readelf -a ./foo | ag interpreter
# # To print the dynamic libraries:
# ldd -v ./foo
# # To find libraries that need patching
# ldd ./foo | grep 'not found'
# # To find the interpreter in NixOS
# cat $NIX_CC/nix-support/dynamic-linker
# # To list the required dynamic libraries
# patchelf --print-needed ./foo

NixFormat() {
    if [ -n "$1" ]; then
        alejandra $@
        return
    fi
    alejandra ./**/*.nix
}
"###,
    );

    if Config::has_config_file(&context.system, ".config/nix-only")
        && !context.system.get_has_binary("home-manager")
    {
        println!("You need to install home-manager packages");
        println!("Run: `nix-shell -p home-manager` and then `SwitchHomeManager`");
        std::process::exit(1);
    }
}

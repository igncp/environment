use crate::base::{config::Config, system::System, Context};

use super::vim::install_nvim_package;

pub fn setup_dotnet(context: &mut Context) {
    if !Config::has_config_file(&context.system, "dotnet") {
        return;
    }

    if !context.system.get_has_binary("dotnet") {
        System::run_bash_command(
            r###"
cd ~ ; rm -rf dotnet-installer ; mkdir dotnet-installer ; cd dotnet-installer
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
sudo chmod +x ./dotnet-install.sh
./dotnet-install.sh --version latest
cd ~ ; rm -rf dotnet-installer
"###,
        );
    }

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools
export DOTNET_CLI_TELEMETRY_OPTOUT=1
"###,
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias DotnetRun='dotnet run'
"###,
    );

    install_nvim_package(context, "OmniSharp/omnisharp-vim", None);
}

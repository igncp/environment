use std::path::Path;

pub use self::gui::run_ubuntu_gui;
pub use self::install::install_ubuntu;
use crate::base::{config::Config, system::System, Context};

mod gui;
mod install;

pub fn run_ubuntu_beginning(context: &mut Context) {
    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export DEBIAN_FRONTEND=noninteractive
export PATH="$PATH:$HOME/nvim/bin"
"###,
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias SystemListInstalled='apt list --installed'
alias SystemUpgrade='sudo apt-get upgrade -y'

alias AptLog='tail -f /var/log/apt/term.log'
alias UbuntuVersion='lsb_release -a'
alias UbuntuFindPackageByFile="dpkg-query -S" # e.g. UbuntuFindPackageByFile '/usr/bin/ag'
"###,
    );

    context.system.install_system_package("python3", None);
    context
        .system
        .install_system_package("python3-pip", Some("pip3"));

    if !context.system.get_has_binary("pip3") {
        System::run_bash_command("sudo cp /usr/bin/pip3 /usr/bin/pip");
    }

    if !Path::new(&context.system.get_home_path(".check-files/ubuntu-dev")).exists() {
        System::run_bash_command(
            r###"
# Used by other provisions like rust
sudo apt-get install -y pkg-config libssl-dev
touch ~/.check-files/ubuntu-dev
"###,
        );
    }

    // This avoids displaying the restart-services popup on every install
    if Path::new("/etc/needrestart/needrestart.conf").exists() {
        System::run_bash_command(
            r###"
sudo sed "s|#\$nrconf{restart}.*|\$nrconf{restart} = 'a';|" -i /etc/needrestart/needrestart.conf
"###,
        );
    }

    // This disables the * when typing a password
    if Path::new("/etc/sudoers.d/0pwfeedback").exists() {
        System::run_bash_command(
            r###"
sudo mv  /etc/sudoers.d/0pwfeedback.disabled
"###,
        );
    }

    if Config::has_config_file(&context.system, ".config/network-analysis") {
        if !context.system.get_has_binary("wireshark") {
            System::run_bash_command(
                r###"
sudo add-apt-repository ppa:wireshark-dev/stable -y
sudo apt-get update
sudo apt-get install wireshark tshark -y
sudo adduser $USER wireshark
"###,
            );
        }

        context.system.install_system_package("mitmproxy", None);
    }

    if !context.system.get_has_binary("nvim") {
        // https://github.com/neovim/neovim/releases/
        if context.system.is_arm() {
            System::run_bash_command(
                r###"
cd ~ ; rm -rf nvim-repo ; git clone https://github.com/neovim/neovim.git nvim-repo --depth 1 --branch release-0.9 ; cd nvim-repo
# https://github.com/neovim/neovim/wiki/Building-Neovim#build-prerequisites
sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
make CMAKE_BUILD_TYPE=Release
make CMAKE_INSTALL_PREFIX=$HOME/nvim install
cd ~ ; rm -rf nvim-repo
"###,
            );
        } else {
            System::run_bash_command(
                r###"
cd /tmp && rm -rf nvim-linux* && wget https://github.com/neovim/neovim/releases/download/v0.9.0/nvim-linux64.tar.gz
tar -xf ./nvim-linux64.tar.gz
rm -rf ~/nvim
mv nvim-linux64 ~/nvim
cd ~
"###,
            );
        }
    }

    System::run_bash_command(
        r####"
# Cleanup of the initial installation
sudo rm -rf /root/.check-files
sudo rm -rf /root/environment
sudo rm -rf /root/.cargo

sudo rm -rf ~/.scripts/motd_update.sh
cat > ~/.scripts/motd_update.sh <<"EOF"
echo "###" > /etc/motd
echo "Message created in $HOME/.scripts/motd_update.sh" >> /etc/motd
echo "Hello!" >> /etc/motd
echo "###" >> /etc/motd
echo "" >> /etc/motd
EOF
sudo chown root:root ~/.scripts/motd_update.sh
"####,
    );

    // @TODO: Automate installing firefox (no snap): https://www.omgubuntu.co.uk/2022/04/how-to-install-firefox-deb-apt-ubuntu-22-04
}

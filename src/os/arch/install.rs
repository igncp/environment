use std::{fs, path::Path};

use crate::{
    base::{system::System, Context},
    os::disk_on_volume::sync_fstab,
};

pub fn install_arch(context: &mut Context) {
    if !context.system.get_has_binary("sudo") {
        System::run_bash_command("pacman -S --noconfirm sudo");
    }

    context.system.install_system_package("ufw", None);
    context.system.install_system_package("git", None);

    let users = fs::read_to_string("/etc/passwd").unwrap();

    if !users.contains("igncp:") {
        System::run_bash_command(
            r###"
useradd igncp -m
echo "Change password on login"
echo "igncp:igncp" | chpasswd
chsh igncp -s /usr/bin/bash
"###,
        );
    }

    let sudoers = fs::read_to_string("/etc/sudoers").unwrap();
    if !sudoers.contains("igncp") {
        System::run_bash_command(
            r###"
echo "# igncp ALL=(ALL) ALL" >> /etc/sudoers
echo "igncp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers # For the initial installation
"###,
        );
    }

    System::run_bash_command(
        r###"
ufw allow ssh
ufw --force enable
"###,
    );
    let profile_file = fs::read_to_string("/etc/profile").unwrap();
    if !profile_file.contains("umask") {
        System::run_bash_command("echo 'umask 0077' >> /etc/profile");
    }

    if !Path::new("/home/igncp/development/environment").exists() {
        System::run_bash_command(
            r###"
mkdir -p /home/igncp/development
cp -r /root/development/environment /home/igncp/development/environment
mkdir -p /home/igncp/development/environment/project/.config
echo "dark" > /home/igncp/development/environment/project/.config/theme
chown -R igncp:igncp /home/igncp/development
"###,
        );
    }

    if !Path::new("/home/igncp/.ssh").exists() {
        System::run_bash_command(
            r###"
cp -r /root/.ssh /home/igncp/.ssh
chown -R igncp:igncp /home/igncp/.ssh
"###,
        );
    }

    if !Path::new("/home/igncp/.cargo").exists() {
        System::run_bash_command(
            r###"
sudo -u igncp bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
"###,
        );
    }

    System::run_bash_command(
        r###"
sudo -u igncp bash -c "mkdir -p ~/.check-files && touch ~/.check-files/install"

if [ ! -f /swapfile ]; then
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi
"###,
    );

    sync_fstab(context);
}

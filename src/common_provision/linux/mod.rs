use std::{fs, path::Path};

use crate::base::{config::Config, system::System, Context};

use self::gui::setup_gui;

mod gui;

pub fn setup_linux(context: &mut Context) {
    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
export PATH="$PATH:/usr/sbin"
"###,
    );

    context.system.install_system_package("lshw", None);

    if !context.system.is_arm() {
        context.system.install_system_package("dmidecode", None);
        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r#"alias LinuxLsHardwareMemory='sudo dmidecode --type 17'"#,
        );
    }

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias JournalctlDiskUsage='sudo journalctl --disk-usage'
alias JournalctlKernel='sudo journalctl -k'
alias JournalctlLsBoots='sudo journalctl --list-boots'
alias JournalctlSystemErrors='sudo journalctl -p 3 -x'
alias JournalctlUnit='sudo journalctl -u' # e.g. JournalctlUnit ufw -b
alias JournalctlUser='sudo journalctl _UID=' # find with `id USER_NAME`

alias LinuxLsCPU='lscpu'
alias LinuxLsHardware='sudo lshw'
alias LinuxLsHardwarePCI='lspci'
alias LinuxLsKernelModules='lsmod'
alias SystemFailed='systemctl --failed'
alias SystemFailedReset='systemctl reset-failed'

alias SystemAnalyzeCriticalChain='systemd-analyze critical-chain'
alias SystemAnalyzePlot='systemd-analyze plot > /tmp/plot.svg && echo "/tmp/plot.svg generated"'
alias SystemAnalyzeTimes='systemd-analyze blame'

FACLRemoveGroupForFile() { sudo setfacl -x g:$1 $2 ; }

alias LsBlkNoLoop='lsblk -e7' # Excludes loop devices, which can accumulate when using snaps: https://askubuntu.com/a/1142405
alias LsInitRAMFS='lsinitcpio /boot/initramfs-linux.img'

alias LabelEXTPartition='sudo e2label' # For example: LabelEXTPartition /dev/sda2 FOO_NAME
alias LabelFAT='sudo fatlabel' # For example: LabelFAT /dev/sda2 FOO_NAME
LabelLuksPartition() { sudo cryptsetup config $1 --label $2; } # For example: LabelLuksPartition /dev/sda2 FOO_NAME

SystemdFindReference() { sudo grep -r "$1" /usr/lib/systemd/system/; }

# Example: TOTP ~/foo-topt.gpg
TOTP() {
  KEY=$(sudo gpg -q -d --pinentry-mode=loopback --no-symkey-cache $1)
  if [ -z "$KEY" ]; then echo "Invalid key"; return; fi
  VALUE=$(oathtool --totp -b "$KEY");
  echo "$VALUE" ; echo "$VALUE" | tr -d '\n' | xclip -selection clipboard
}

alias HongKongTimezone='sudo timedatectl set-timezone Asia/Hong_Kong'
alias MadridTimezone='sudo timedatectl set-timezone Europe/Madrid'
alias TimeSyncRestart='sudo systemctl restart systemd-timesyncd.service'
alias TimeSyncShow='timedatectl show-timesync --all'
alias TimeSyncStatus='timedatectl timesync-status'
alias TimezoneShow='timedatectl status'
alias TokyoTimezone='sudo timedatectl set-timezone Asia/Tokyo'

GrubHideSetupTimeout() {
  sudo sed -i 's|^GRUB_TIMEOUT=.*|GRUB_TIMEOUT=1|' /etc/default/grub
  sudo sed -i 's|^GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=hidden|' /etc/default/grub
}

LinuxSwappinessUpdate() {
  echo 'vm.swappiness=10' > /tmp/99-swappiness.conf
  echo 'vm.vfs_cache_pressure=50' >> /tmp/99-swappiness.conf
  echo 'vm.dirty_ratio=3' >> /tmp/99-swappiness.conf
  sudo mv /tmp/99-swappiness.conf /etc/sysctl.d/
}
"###
    );

    // https://www.geeksforgeeks.org/iotop-command-in-linux-with-examples
    // sudo iotop -o -n 2 -t -b
    context.system.install_system_package("iotop", None);

    if !Path::new(&context.system.get_home_path(".check-files/swappiness")).exists() {
        println!("[~/.check-files/swappiness]: Decide whether to use SwappinessUpdate and hide this message");
    }

    // LVM
    // Creation: lvcreate --size 10G -n home ubuntu-vg # use mkfs.ext4 and mount (for fstab) after
    // For extending: lvextend -L +8G /dev/mapper/lv-foo ; resize2fs /dev/mapper/lv-foo
    // lvdisplay

    // Performance

    if Path::new("/proc/sys/kernel/nmi_watchdog").exists()
        && !Path::new(&context.system.get_home_path(".check-files/watchdog")).exists()
    {
        System::run_bash_command(
            r###"
if [ -n "$(grep 1 /proc/sys/kernel/nmi_watchdog)" ] && [ -f /boot/grub/grub.cfg ] && [ -z "$(grep watchdog /boot/grub/grub.cfg)" ]; then
    echo "[~/.check-files/watchdog]: Add 'nmi_watchdog=0' to the kernel params in grub to disable watchdog or hide this message"
fi
"###,
        );
    }

    if !Path::new(&context.system.get_home_path(".check-files/noatime")).exists()
        && fs::read_to_string("/etc/fstab")
            .unwrap()
            .contains("noatime")
    {
        println!( "[~/.check-files/noatime]: Replace relatime with noatime in fstab and hide this message");
    }

    std::fs::create_dir_all(context.system.get_home_path(".gnupg")).unwrap();
    context.files.appendln(
        &context.system.get_home_path(".gnupg/gpg-agent.conf"),
        "pinentry-program /usr/bin/pinentry-tty",
    );

    context.system.install_system_package("strace", None);

    // Disable the PC loud beep
    if !Path::new("/etc/modprobe.d/nobeep.conf").exists() {
        System::run_bash_command(
            r###"
echo 'blacklist pcspkr' > /tmp/nobeep.conf
sudo mv /tmp/nobeep.conf /etc/modprobe.d/
"###,
        );
    }

    if !context.system.is_nixos() {
        if Config::has_config_file(&context.system, ".config/tailscale")
            && !Path::new(&context.system.get_home_path(".check-files/tailscale")).exists()
        {
            System::run_bash_command("curl -fsSL https://tailscale.com/install.sh | sh");
            System::run_bash_command(
                r###"
if [ -n "$(sudo systemctl list-units | grep tailscaled || true)" ]; then
    sudo systemctl enable --now tailscaled
else
    sudo systemctl enable --now tailscale
fi
touch ~/.check-files/tailscale
"###,
            );
        }
    }

    if !Path::new(&context.system.get_home_path(".check-files/oomd")).exists()
        && !context.system.is_nix_provision
    {
        System::run_bash_command(
            r###"
if [ -n "$(systemctl list-units --full -all | grep systemd-oomd)" ]; then
    sudo systemctl enable --now systemd-oomd
fi
touch ~/.check-files/oomd
"###,
        );
    }

    if Config::has_config_file(&context.system, ".config/netdata") {
        context.system.install_system_package("netdata", None);
        if !Path::new(&context.system.get_home_path(".check-files/netdata")).exists() {
            System::run_bash_command(
                r###"
sudo systemctl enable --now netdata
touch ~/.check-files/netdata
"###,
            );
        }
    }

    // https://wiki.archlinux.org/title/Google_Authenticator
    if Config::has_config_file(&context.system, ".config/gauth-pam") {
        context
            .system
            .install_system_package("libpam-google-authenticator", Some("google-authenticator"));
        // - `/etc/pam.d/sshd`: `auth required pam_google_authenticator.so`
        // - `/etc/ssh/sshd_config`: `KbdInteractiveAuthentication yes`
        // - `/etc/ssh/sshd_config`: `AuthenticationMethods keyboard-interactive:pam,publickey`
    }

    // For arch
    if !context.system.get_has_binary("crond") && !context.system.is_nixos() {
        // For ubuntu
        if !context.system.get_has_binary("cron") && !context.system.is_debian() {
            context
                .system
                .install_system_package("cronie", Some("crond"));
            System::run_bash_command("sudo systemctl enable --now cronie");
        }
    }

    if context.system.get_has_binary("crond") {
        System::run_bash_command(
            r###"
sudo touch /var/spool/cron/"$USER"
sudo touch /var/spool/cron/root
sudo chown "$USER" /var/spool/cron/"$USER"
printf '' > /var/spool/cron/"$USER"
sudo sh -c "printf '' > /var/spool/cron/root"

# /etc/motd is read by /etc/pam.d/system-login
sudo sh -c "echo '*/10 * * * * sh /home/$USER/.scripts/motd_update.sh' >> /var/spool/cron/root"
sudo touch /etc/motd
sudo chmod o+r /etc/motd
"###,
        );

        // @TODO: setup alias for this
        // echo '- swap: https://wiki.archlinux.org/index.php/swap'
        // echo '    sudo su # can create the swapfile inside the home directory if bigger volume'
        // echo '    dd if=/dev/zero of=/swapfile bs=1G count=10 status=progress # RAM size + 2G, in this case 10 GB Swap'
        // echo "    chmod 600 /swapfile ; mkswap /swapfile ; swapon /swapfile ; echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab"

        // @TODO: Check if it is Ubuntu to do this
        // crontab /var/spool/cron/"$USER"
        // sudo crontab /var/spool/cron/root
    }

    context.system.install_system_package("vnstat", None);

    context.system.install_system_package("speedtest-cli", None);

    if Config::has_config_file(&context.system, ".config/usb-modem") {
        context
            .system
            .install_system_package("modemmanager", Some("ModemManager"));
        context
            .system
            .install_system_package("usb_modeswitch", None);
        context
            .system
            .install_system_package("nm-connection-editor", None);
        context.system.install_system_package("wvdial", None);
        context
            .system
            .install_system_package("libmbim", Some("mbimcli"));

        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
alias USBModemManagerStart='sudo systemctl start ModemManager'
alias USBModemManagerList='sudo mmcli --list-modems'
alias USBModemShowModem0='sudo mmcli --modem=/org/freedesktop/ModemManager1/Modem/0' # from USBModemManagerList
USBModemSetPin() { sudo mmcli --sim=/org/freedesktop/ModemManager1/SIM/0 --pin="$1"; }
"###,
        );
    }

    setup_gui(context);
}

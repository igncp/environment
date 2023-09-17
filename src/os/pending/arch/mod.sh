# @TODO
# pub use self::gui::run_arch_gui;
# pub use self::install::install_arch;
# use crate::base::{config::Config, system::System, Context};
# use std::path::Path;

# mod gui;
# mod install;

# pub fn install_from_aur(context: &mut Context, binary: &str, repo: &str) {
#     if !context.system.get_has_binary(binary) {
#         System::run_bash_command(&format!(
#             r###"
# TMP_DIR=$(mktemp -d)
# cd "$TMP_DIR"
# git clone "{repo}"
# cd ./*
# makepkg -si --noconfirm
# cd; rm -rf "$TMP_DIR"
# "###
#         ));
#     }
# }

# pub fn install_with_yay(context: &mut Context, package_name: &str, binary: Option<&str>) {
#     let used_binary = match binary {
#         Some(b) => b,
#         None => package_name,
#     };

#     if !context.system.get_has_binary(used_binary) {
#         let cmd = format!("yay -S --noconfirm {package_name}");
#         println!("Doing: {cmd}");
#         System::run_bash_command(&cmd);
#     }
# }

# pub fn run_arch_beginning(context: &mut Context) {
#     let basic_check_files = context.system.get_home_path(".check-files/basic-packages");

#     if !Path::new(&basic_check_files).exists() {
#         System::run_bash_command(&format!(
#             r###"
# echo "Installing basic packages"
# sudo pacman -Syu --noconfirm
# sudo pacman -S --noconfirm bash-completion
# sudo pacman -S --noconfirm xscreensaver libxss # Required by dunst

# touch {basic_check_files}
# "###
#         ))
#     }

#     if !context.system.get_has_binary("yay") {
#         // Required by yay
#         System::run_bash_command("sudo pacman -S --noconfirm base-devel");
#     }

#     install_from_aur(context, "yay", "https://aur.archlinux.org/yay-git.git");

#     context.files.append(
#         &context.system.get_home_path(".shell_aliases"),
#         r###"
# TimeManualSet() {
#   sudo systemctl stop systemd-timesyncd.service
#   sudo timedatectl set-time "$1" # "yyyy-MM-DD HH:MM:SS"
# }

# alias TimeManualUnset='sudo systemctl restart systemd-timesyncd.service'

# alias PacmanCacheCleanHard='sudo pacman -Scc'
# alias PacmanCacheCleanLight='sudo pacman -Sc'
# alias PacmanFindPackageOfFile='pacman -Qo'
# alias PacmanListExplicitPackages='pacman -Qe'
# alias PacmanListFilesOfPackage='pacman -Ql'
# alias PacmanListInstalledPackages='sudo pacman -Qs'
# alias PacmanListPackagesByDate="expac --timefmt='%Y-%m-%d %T' '%l\t%n' | sort"
# alias PacmanListUpdates='sudo pacman -Sy ; pacman -Sup'
# alias PacmanSearchPackage='pacman -F'
# alias PacmanUpdateRepos='sudo pacman -Sy'

# alias SystemClean='sudo pacman -Sc'
# alias SystemUpgrade='sudo pacman -Syu && yay -Syu --noconfirm'
# "###,
#     );

#     // network
#     context.files.append(
#         &context.system.get_home_path(".shell_aliases"),
#         r###"
# WifiConnect() {
#   sudo wifi-menu
#   sudo dhcpcd
# }
# "###,
#     );

#     // To enable Wifi network
#     // ls -lah /etc/netctl # find the profile name
#     // sudo netctl enable PROFILE_NAME

#     context
#         .system
#         .install_system_package("base-devel", Some("make"));
#     context.system.install_system_package("nmap", None);
#     context.system.install_system_package("lftp", None);

#     context
#         .system
#         .install_system_package("apparmor", Some("apparmor_status"));
#     if !Path::new(&context.system.get_home_path(".check-files/apparmor-config")).exists() {
#         System::run_bash_command(
#             r###"
# sudo pacman -S --noconfirm audit
# sudo systemctl enable --now apparmor
# sudo groupadd -r audit || true
# sudo gpasswd -a "$USER" audit || true
# sudo sed -i 's|^log_group =.*|log_group = audit|' /etc/audit/auditd.conf
# sudo systemctl enable --now auditd
# touch ~/.check-files/apparmor-config
# "###,
#         );
#     }

#     // For example:
#     // - `sudo iostat /dev/sda1 1` # Monitors IO (read/write speeds) every second
#     // - `sudo iostat` # Stats for all devices
#     context
#         .system
#         .install_system_package("sysstat", Some("iostat"));

#     // Power saving diagnostics
#     context.system.install_system_package("powertop", None);

#     if !context.system.is_arm() {
#         context.system.install_system_package("hwinfo", None);
#         context.system.install_system_package("i7z", None);
#     }
#     context.system.install_system_package("cpupower", None);

#     install_with_yay(context, "cpupower-gui", None);

#     context.system.install_system_package("expac", None);

#     // When using GUI, there is a GTK tray icon to check for CVEs
#     context.system.install_system_package("arch-audit", None);

#     context
#         .system
#         .install_system_package("oath-toolkit", Some("oathtool"));

#     context
#         .system
#         .install_system_package("usbutils", Some("lsusb"));

#     // Wiki: https://wiki.archlinux.org/title/USBGuard
#     // Rules: https://github.com/USBGuard/usbguard/blob/master/doc/man/usbguard-rules.conf.5.adoc
#     context.system.install_system_package("usbguard", None);
#     context.files.append(&context.system.get_home_path(".shell_aliases"), r###"
# function USBGuardInit() {
#   sudo sed -i 's|IPCAllowedUsers=root|IPCAllowedUsers=root '"$USER"'|' /etc/usbguard/usbguard-daemon.conf
#   sudo bash -c 'usbguard generate-policy > /etc/usbguard/rules.conf'
#   sudo systemctl enable --now usbguard
# }
# alias USBGuardBlocked='usbguard list-devices --blocked'
# alias USBGuardAllowPermanently='usbguard allow-device -p'
# "###);

#     // Autocomplete for sudo
#     context.files.appendln(
#         &context.system.get_home_path(".bashrc"),
#         "complete -cf sudo",
#     );

#     context.files.appendln(
#         &context.system.get_home_path(".shell_aliases"),
#         "alias GPGPinentryList='pacman -Ql pinentry | grep /usr/bin/'",
#     );

#     // Benchmarking
#     install_with_yay(context, "sysbench", None);

#     context.system.install_system_package("qrencode", None);
#     context.files.appendln(
#         &context.system.get_home_path(".shell_aliases"),
#         "alias QRTerminal='qrencode -t UTF8'",
#     );

#     if context.system.get_has_binary("zramd") {
#         install_with_yay(context, "zramd", None);
#         System::run_bash_command("sudo systemctl enable --now zramd");
#     }

#     if !context.system.get_has_binary("pkgfile") {
#         System::run_bash_command(
#             r###"
# sudo pacman -S --noconfirm pkgfile
# sudo pkgfile -u
# "###,
#         );
#     }
#     context.files.appendln(
#         &context.system.get_home_path(".bashrc"),
#         "source /usr/share/doc/pkgfile/command-not-found.bash",
#     );
#     context.files.appendln(
#         &context.system.get_home_path(".zshrc"),
#         "source /usr/share/doc/pkgfile/command-not-found.zsh",
#     );

#     if !Config::has_config_file(&context.system, ".config/tlp") {
#         context.system.install_system_package("tlp", None);
#         context.system.install_system_package("tlp-rdw", None);

#         if !Path::new(&context.system.get_home_path(".check-files/tlp")).exists() {
#             System::run_bash_command(
#                 r###"
# sudo systemctl enable --now tlp
# sudo systemctl mask systemd-rfkill.service
# sudo systemctl mask systemd-rfkill.socket

# touch ~/.check-files/tlp
# "###,
#             );
#         }
#     }

#     System::run_bash_command("sudo rm -rf ~/.scripts/motd_update.sh");

#     context.files.append(
#         &context.system.get_home_path(".scripts/motd_update.sh"),
#         r####"
# pacman -Sy > /dev/null
# UPDATES="$(pacman -Sup | wc -l)"
# echo "###" > /etc/motd
# echo "Message created in $HOME/.scripts/motd_update.sh" >> /etc/motd
# echo "Available pacman updates: $UPDATES" >> /etc/motd
# echo "###" >> /etc/motd
# echo "" >> /etc/motd
# "####,
#     );
#     context.write_file(
#         &context.system.get_home_path(".scripts/motd_update.sh"),
#         true,
#     );

#     System::run_bash_command("sudo chown root:root ~/.scripts/motd_update.sh");
# }

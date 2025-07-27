# @TODO
# use crate::{
#     base::{config::Config, Context},
#     os::arch::install_with_yay,
# };

# pub fn setup_apps(context: &mut Context) {
#     if context.system.is_arm() {
#         install_with_yay(context, "chromium", None);
#     }

#     // https://zoom.us/download?os=linux
#     // sudo pacman -U ./zoom_x86_64.pkg.tar.xz
#     if Config::has_config_file(&context.system, ".config/gui-zoom") {
#         install_with_yay(context, "zoom", None);
#     }

#     if Config::has_config_file(&context.system, ".config/gui-mysql-workbench") {
#         context
#             .system
#             .install_system_package("mysql-workbench", None);
#         context.system.install_system_package("gnome-keyring", None);
#     }

#     if Config::has_config_file(&context.system, ".config/gui-pdfsam") {
#         // PDF manipulation
#         install_with_yay(context, "pdfsam", None);
#     }

#     // Wallpapers
#     install_with_yay(context, "variety-git", Some("variety"));

#     // Desktop magnifier: https://github.com/stuartlangridge/magnus
#     install_with_yay(context, "magnus", None);

#     if Config::has_config_file(&context.system, ".config/gui-skype") {
#         install_with_yay(context, "skypeforlinux-stable-bin", Some("skypeforlinux"));
#     }

#     if Config::has_config_file(&context.system, ".config/gui-postman") {
#         install_with_yay(context, "postman-bin", Some("postman"));
#     }

#     // For Dropbox, install manually the Yay package: https://aur.archlinux.org/packages/dropbox
#     // It has a tray icon
#     // Download the gpg key and import it with: `gpg --import rpm-public-key.asc`

#     context.system.install_system_package("peek", None);
#     context.system.install_system_package("flameshot", None);
#     context.system.install_system_package("lxappearance", None); // Gnome themes

#     install_with_yay(context, "realvnc-vnc-viewer", Some("vncviewer"));
# }

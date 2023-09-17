# @TODO
# use std::path::Path;

# use crate::base::{system::System, Context};

# use self::{apps::setup_apps, dunst::setup_dunst, nvidia::setup_nvidia, vnc::setup_vnc};

# use super::install_with_yay;

# mod apps;
# mod dunst;
# mod nvidia;
# mod vnc;

# pub fn run_arch_gui(context: &mut Context) {
#     context.system.install_system_package("pulseaudio", None);
#     context.system.install_system_package("pavucontrol", None); // For audio settings

#     if !context.system.get_has_binary("gvim") {
#         System::run_bash_command(r###"sudo pacman -R --noconfirm vim"###);

#         context.system.install_system_package("gvim", None); // Adds support to clipboard to vim
#     }

#     context.system.install_system_package("xsel", None);

#     if !Path::new(&context.system.get_home_path(".check-files/arch-fonts")).exists() {
#         System::run_bash_command(
#             r###"
# sudo pacman -S --noconfirm \
#     adobe-source-han-sans-jp-fonts \
#     adobe-source-han-serif-jp-fonts \
#     noto-fonts \
#     noto-fonts-cjk \
#     noto-fonts-emoji \
#     ttf-font-awesome \
#     otf-ipafont
# touch ~/.check-files/arch-fonts
# "###,
#         )
#     }

#     if !Path::new(&context.system.get_home_path(".check-files/nerd-fonts")).exists() {
#         // https://github.com/ryanoasis/vim-devicons
#         install_with_yay(context, "nerd-fonts-source-code-pro", None);

#         System::run_bash_command("touch ~/.check-files/nerd-fonts");
#     }

#     // Enable autologin: https://wiki.archlinux.org/title/LightDM#Enabling_autologin
#     if !Path::new(&context.system.get_home_path(".check-files/lightdm")).exists() {
#         System::run_bash_command(
#             r###"
# sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
# sudo systemctl enable --now lightdm.service
# # sudo pacman -S --noconfirm accountsservice # to fix a journalctl error
# touch ~/.check-files/lightdm
#             "###,
#         );
#     }

#     install_with_yay(context, "google-chrome", Some("google-chrome-stable"));

#     System::run_bash_command(
#         r###"
# rm -rf ~/.xprofile
# ln -s ~/.xinitrc ~/.xprofile

# echo '' > ~/.config/chrome-flags.conf

# cat >> ~/.config/chrome-flags.conf <<"EOF"
# --force-dark-mode
# --enable-features=WebUIDarkMode
# EOF

# mkdir -p ~/.config/fontconfig
# cp ~/development/environment/unix/config-files/fonts.conf ~/.config/fontconfig
# "###,
#     );

#     context.home_appendln(".shell_aliases", r#"alias FontsList="fc-list""#);

#     if !Path::new(&context.system.get_home_path(".check-files/bluetooth")).exists() {
#         System::run_bash_command(
#             r###"
# sudo pacman -S --noconfirm bluez-utils
# sudo pacman -S --noconfirm bluez
# sudo pacman -S --noconfirm pulseaudio-bluetooth
# sudo systemctl enable --now bluetooth.service
# touch ~/.check-files/bluetooth
# "###,
#         );
#     }

#     setup_dunst(context);
#     setup_vnc(context);
#     setup_apps(context);
#     setup_nvidia(context);
# }

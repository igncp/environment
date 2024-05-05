# use std::path::Path;

# use crate::base::{config::Config, system::System, Context};

# pub fn setup_rime(context: &mut Context) {
#     if !Config::has_config_file(&context.system, ".config/rime") {
#         return;
#     }

#     if context.system.is_mac() {
#         println!("Mac provision for Rime is missing");

#         return;
#     }

#     context.home_append(
#         ".xinitrc",
#         r###"
# export GTK_IM_MODULE=ibus
# export XMODIFIERS=@im=ibus
# export QT_IM_MODULE=ibus
# export QT4_IM_MODULE=ibus
# "###,
#     );

#     if !Path::new("/usr/share/themes/Menta").exists() {
#         context.system.install_system_package("mate-themes", None);
#     }

#     if !context.system.get_has_binary("rime_deployer") && !context.system.is_nixos() {
#         let current_value = context.system.is_nix_provision;
#         context.system.is_nix_provision = false;
#         context.system.install_system_package("ibus", None);
#         context.system.install_system_package("ibus-rime", None);
#         context.system.is_nix_provision = current_value;
#     }

#     let config_path = &context
#         .system
#         .get_home_path(".config/ibus/rime/default.yaml");

#     // On RIME, press F4 to switch
#     // On IBusSettings, add English and Chinese - RIME
#     if !Path::new(
#         &context
#             .system
#             .get_home_path(".check-files/ibus-shortcut-log"),
#     )
#     .exists()
#     {
#         println!("[~/.check-files/ibus-shortcut-log]: In ibus settings, change the default Super+Space shortcut to switch IM to Alt+l (language)");
#     }

#     context.home_append(
#         ".shell_aliases",
#         &format!(
#             r###"
# alias IBusDaemon='ibus-daemon -drx'
# alias IBusSettings='IBUS_PREFIX= python2 /usr/share/ibus/setup/main.py'
# RimeConfigure() {{
#   $EDITOR -p ~/development/environment/src/config-files/rime-config.yaml
#   cp ~/development/environment/src/config-files/rime-config.yaml {config_path}
#   echo Copied Rime config file
# }}
# "###,
#         ),
#     );

#     //   echo 'GTK_THEME=Menta /usr/bin/ibus-daemon -rxd' >> ~/.scripts/gui_daemons.sh
# }

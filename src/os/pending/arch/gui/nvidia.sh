# @TODO
# use std::path::Path;

# use crate::base::{config::Config, system::System, Context};

# pub fn setup_nvidia(context: &mut Context) {
#     if !Config::has_config_file(&context.system, ".config/nvidia") {
#         println!(
#             "[~/development/environment/project/.config/nvidia] File is missing, add it with 'yes' or 'no' to install nvidia packages"
#         );

#         return;
#     }

#     // Read file using std library
#     let nvidia_file = std::fs::read_to_string(Config::get_config_file_path(
#         &context.system,
#         ".config/nvidia",
#     ))
#     .expect("Something went wrong reading the file");

#     if nvidia_file.trim() != "yes" {
#         return;
#     }

#     context
#         .system
#         .install_system_package("nvidia", Some("nvidia-smi"));
#     context
#         .system
#         .install_system_package("nvidia-settings", None);

#     if !Path::new(
#         &context
#             .system
#             .get_home_path(".check-files/nvidia-installed"),
#     )
#     .exists()
#     {
#         System::run_bash_command(
#             r###"
# sudo pacman -S --noconfirm nvidia-utils mesa
# touch ~/.check-files/nvidia-installed
# "###,
#         );
#     }

#     System::run_bash_command(
#         r###"
# cat > ~/.scripts/nvidia-config.sh <<"EOF"
# #!/usr/bin/env bash
# if [ ! -f "$HOME"/.nvidia-settings-rc ]; then
#     exit
# fi
# sed -i 's|Brightness=.*|Brightness=-0.710000|g' "$HOME"/.nvidia-settings-rc
# sed -i 's|Contrast=.*|Contrast=-0.710000|g' "$HOME"/.nvidia-settings-rc
# sed -i 's|Gamma=.*|Gamma=1.087667|g' "$HOME"/.nvidia-settings-rc
# nvidia-settings --load-config-only
# EOF

# if [ ! -f "$HOME"/.nvidia-settings-rc ]; then
#     echo "$HOME/.nvidia-settings-rc doesn't exist. Run 'nvidia-settings' to generate it"
# fi
# sed -i "1isleep 5s && sh $HOME/.scripts/nvidia-config.sh" ~/.xinitrc
# "###,
#     );
# }

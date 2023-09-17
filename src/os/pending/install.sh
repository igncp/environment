# @TODO
# use std::{path::Path, process};

# use crate::base::{
#     system::{LinuxDistro, System, OS},
#     Context,
# };

# use super::{arch, disk_on_volume::setup_disk_on_volume, ubuntu};

# pub fn setup_os_install(context: &mut Context) {
#     if context.system.is_windows() {
#         return;
#     }

#     if context.system.is_linux() && !context.system.is_nixos() {
#         context
#             .system
#             .install_system_package("arch-install-scripts", Some("genfstab"));
#     }

#     let install_file = context.system.get_home_path(".check-files/install");

#     if !Path::new(&install_file).exists() {
#         setup_disk_on_volume(context);

#         if context.system.os == OS::Linux {
#             let distro = context.system.linux_distro.clone().unwrap();

#             match distro {
#                 LinuxDistro::Ubuntu | LinuxDistro::Debian => {
#                     ubuntu::install_ubuntu(context);
#                 }
#                 LinuxDistro::Arch => {
#                     arch::install_arch(context);
#                 }
#                 _ => {}
#             }
#         }

#         System::run_bash_command(&format!("mkdir -p ~/.check-files && touch {install_file}"));
#         if context.system.os == OS::Linux {
#             println!(
#                 "Root installation finished, now you can SSH as igncp and run the installation again"
#             );
#             process::exit(0);
#         }
#     }
# }

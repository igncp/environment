# @TODO
# use std::path::Path;

# use crate::base::{system::System, Context};

# use self::{komorebi::setup_komorebi, utils::install_windows_package};

# use super::{get_vscode_settings_multi_os, multi_os_provision::get_vscode_keybindings_multi_os};

# pub use self::utils::append_json_into_vs_code;

# mod komorebi;
# mod utils;

# fn check_ahk_shortcut(context: &mut Context, file_name: &str) {
#     if !Path::new(&context.system.get_home_path(&format!(
#         "AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\{}.lnk",
#         file_name
#     )))
#     .exists()
#     {
#         println!(
#             "Open the startup dir with 'ExplorerStartup' and create a shortcut for '{}'",
#             file_name
#         );
#     }
# }

# pub fn run_windows(context: &mut Context) {
#     let current_shell = std::env::var_os("SHELL");
#     if current_shell.is_none() {
#         println!("Windows provision is only supported in Git Bash");
#         std::process::exit(1);
#     }

#     let current_shell = current_shell.unwrap().to_str().unwrap_or("_").to_string();
#     if !current_shell.contains("bash") {
#         println!("Windows provision is only supported in Git Bash");
#         std::process::exit(1);
#     }

#     let vscode_settings = get_vscode_settings_multi_os();
#     append_json_into_vs_code(context, "User\\settings.json", &vscode_settings);

#     let keybindings = get_vscode_keybindings_multi_os();
#     append_json_into_vs_code(context, "User\\keybindings.json", &keybindings);

#     std::fs::create_dir_all(context.system.get_home_path("AppData\\Local\\nvim")).unwrap();

#     let vim_str = std::fs::read_to_string(
#         context
#             .system
#             .get_home_path("development/environment/src/config-files/mult-os.vim"),
#     )
#     .unwrap_or("".to_string());
#     let vim_str = format!(
#         r###"
# {}
# " Save file shortcuts
# nmap <c-e> :update<esc>
# inoremap <c-e> <esc>:update<cr>
# "###,
#         vim_str
#     );

#     context
#         .files
#         .append(&context.system.get_home_path(".vimrc"), &vim_str);

#     context.files.append(
#         &context
#             .system
#             .get_home_path("AppData\\Local\\nvim\\init.vim"),
#         &vim_str,
#     );

#     check_ahk_shortcut(context, "switch-same-app.ahk");
#     check_ahk_shortcut(context, "capslock.ahk");

#     setup_komorebi(context);

#     if !Path::new(
#         &context
#             .system
#             .get_home_path("development/environment/project/target/release/clipboard_ssh.exe"),
#     )
#     .exists()
#     {
#         System::run_bash_command(
#             "cd ~/development/environment/src/scripts/misc/clipboard_ssh && cargo build --release",
#         );
#     }
# }

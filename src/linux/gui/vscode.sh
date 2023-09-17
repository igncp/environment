# use std::path::Path;

# use crate::{
#     base::{config::Config, system::System, Context},
#     os::{get_vscode_keybindings_multi_os, get_vscode_settings_multi_os},
# };

# pub fn setup_vscode(context: &mut Context) {
#     if !Config::has_config_file(&context.system, ".config/vscode") {
#         return;
#     }

#     if !context.system.get_has_binary("code") {
#         if context.system.is_mac() {
#             println!("Install vscode for Mac manually");
#         } else if Path::new(&context.system.get_home_path("Downloads/vscode.tar.gvz")).exists() {
#             System::run_bash_command(
#                 r###"
# (cd "$HOME"/Downloads \
#   && sudo rm -rf /usr/bin/code /opt/visual-studio-code "$HOME"/Downloads/VSCode-* \
#   && tar xf vscode.tar.gz \
#   && sudo mv VSCode-* /opt/visual-studio-code \
#   && sudo ln -s /opt/visual-studio-code/bin/code /usr/bin/code \
#   && rm -rf vscode.tar.gz)
# "###,
#             )
#         } else {
#             println!(
#                 "Not installing VS Code because the file '~/Downloads/vscode.tar.gz' is missing."
#             );
#             println!("  https://code.visualstudio.com/#alt-downloads");
#         }
#     }

#     let vscode_settings = get_vscode_settings_multi_os();
#     context.files.append_json(
#         &context
#             .system
#             .get_home_path(".config/Code/User/settings.json"),
#         &vscode_settings,
#     );

#     let keybindings = get_vscode_keybindings_multi_os();
#     context.files.append_json(
#         &context
#             .system
#             .get_home_path(".config/Code/User/keybindings.json"),
#         &keybindings,
#     );

#     context.files.append(
#         &context.system.get_home_path(".shell_aliases"),
#         r###"
# V() {
#   code $(find $1 -type f | fzf)
# }
# VSCodeCompareExtensions() {
#   code --list-extensions | sort > /tmp/vscode-extensions
#   sort /tmp/expected-vscode-extensions > /tmp/_tmp-sort
#   mv /tmp/_tmp-sort /tmp/expected-vscode-extensions
#   diff -u /tmp/expected-vscode-extensions /tmp/vscode-extensions --color=always
# }
# VSCodeInstallExpectedExtensions() {
#   code --list-extensions | sort > /tmp/vscode-extensions
#   sort /tmp/expected-vscode-extensions > /tmp/_tmp-sort
#   mv /tmp/_tmp-sort /tmp/expected-vscode-extensions
#   diff /tmp/expected-vscode-extensions /tmp/vscode-extensions --color=never | ag '<' \
#     | sed 's|< ||' | xargs -I {} code --install-extension {}
# }
# "###,
#     );

#     context.files.append(
#         &context
#             .system
#             .get_home_path("/tmp/expected-vscode-extensions"),
#         r###"
# waderyan.gitblame
# ms-vscode-remote.remote-ssh
# ms-vscode-remote.remote-ssh-edit
# sleistner.vscode-fileutils
# "###,
#     );

#     if Config::has_config_file(&context.system, ".config/copilot") {
#         context.files.appendln(
#             &context
#                 .system
#                 .get_home_path("/tmp/expected-vscode-extensions"),
#             "GitHub.copilot",
#         );
#     }
# }

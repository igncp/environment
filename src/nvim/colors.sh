# @TODO
# use crate::base::{
#     config::{Config, Theme},
#     Context,
# };

# // https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
# pub fn update_vim_colors_theme(context: &mut Context) {
#     if context.config.theme == Theme::Light {
#         return;
#     }

#     if Config::has_config_file(&context.system, ".config/vim-theme") {
#         return;
#     } else {
#         context.files.appendln(
#             &context.system.get_home_path(".vimrc"),
#             "so ~/.vim/colors.vim",
#         );
#     }

#     fn swap_colors(context: &mut Context, color1: &str, color2: &str) {
#         context.files.replace(
#             &context.system.get_home_path(".vim/colors.vim"),
#             format!("={color1}").as_str(),
#             format!("=TMP_{color2}").as_str(),
#         );
#         context.files.replace(
#             &context.system.get_home_path(".vim/colors.vim"),
#             format!("={color2}").as_str(),
#             format!("={color1}").as_str(),
#         );
#         context.files.replace(
#             &context.system.get_home_path(".vim/colors.vim"),
#             format!("=TMP_{color2}").as_str(),
#             format!("={color2}").as_str(),
#         );
#     }

#     swap_colors(context, "black", "white");
#     swap_colors(context, "darkgrey", "lightgrey");
#     swap_colors(context, "darkcyan", "lightcyan");
#     swap_colors(context, "darkgreen", "lightgreen");
#     swap_colors(context, "darkblue", "lightblue");
#     swap_colors(context, "darkred", "lightred");
#     swap_colors(context, "darkyellow", "lightyellow");

#     context.files.replace(
#         &context.system.get_home_path(".vim/colors.vim"),
#         "=darkcyan",
#         "=18",
#     );
# }

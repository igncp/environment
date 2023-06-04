use std::path::Path;

use crate::base::{config::Theme, system::System, Context};

pub fn install_vim_package(context: &mut Context, repo: &str, extra_cmd: Option<&str>) {
    let dir = repo.split('/').last().unwrap();

    if !Path::new(&format!("{}/.vim/bundle/{}", context.system.home, dir)).exists() {
        println!("Installing vim package: {}", repo);
        System::run_bash_command(
            format!("git clone --depth=1 https://github.com/{repo}.git ~/.vim/bundle/{dir}")
                .as_str(),
        );

        if let Some(cmd) = extra_cmd {
            System::run_bash_command(cmd);
        }
    }
}

// These maps will be present in a fzf list (apart from working normally)
// They must begin with <leader>zm (where <leader> == <Space>)
pub fn add_special_vim_map(context: &mut Context, params: [&str; 3]) {
    let map_keys_after_leader = params[0];
    let map_end = params[1];
    let map_comment = params[2];

    context.files.appendln(
        &context.system.get_home_path(".vimrc"),
        format!("nnoremap <leader>zm{map_keys_after_leader} {map_end}",).as_str(),
    );

    context.files.appendln(
        &context
            .system
            .get_home_path(".special-vim-maps-from-provision.txt"),
        format!("<Space>zm{map_keys_after_leader} -- {map_comment}").as_str(),
    );
}

// https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
pub fn update_vim_colors_theme(context: &mut Context) {
    context
        .files
        .replace(&context.system.get_home_path(".vimrc"), "syntax off", "");

    if context.config.theme == Theme::Light {
        return;
    }

    fn swap_colors(context: &mut Context, color1: &str, color2: &str) {
        context.files.replace(
            &context.system.get_home_path(".vim/colors.vim"),
            format!("={color1}").as_str(),
            format!("=TMP_{color2}").as_str(),
        );
        context.files.replace(
            &context.system.get_home_path(".vim/colors.vim"),
            format!("={color2}").as_str(),
            format!("={color1}").as_str(),
        );
        context.files.replace(
            &context.system.get_home_path(".vim/colors.vim"),
            format!("=TMP_{color2}").as_str(),
            format!("={color2}").as_str(),
        );
    }

    swap_colors(context, "black", "white");
    swap_colors(context, "darkgrey", "lightgrey");
    swap_colors(context, "darkcyan", "lightcyan");
    swap_colors(context, "darkgreen", "lightgreen");
    swap_colors(context, "darkblue", "lightblue");
    swap_colors(context, "darkred", "lightred");
    swap_colors(context, "darkyellow", "lightyellow");

    context.files.replace(
        &context.system.get_home_path(".vim/colors.vim"),
        "=darkcyan",
        "=18",
    );
}

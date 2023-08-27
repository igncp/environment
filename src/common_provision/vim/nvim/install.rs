use crate::base::{
    config::{Config, Theme},
    Context,
};

pub fn install_nvim_package(context: &mut Context, repo: &str, extra_cmd: Option<&str>) {
    let extra = match extra_cmd {
        Some(cmd) => format!(r#", build = "{}""#, cmd),
        None => "".to_string(),
    };
    context.files.replace(
        &context.system.get_home_path(".vim/lua/extra_beginning.lua"),
        r#"local nvim_plugins = {"#,
        &format!(
            r###"local nvim_plugins = {{
{{ "{}"{} }},"###,
            repo, extra
        ),
    );
}

// These maps will be present in a fzf list (apart from working normally)
// They must begin with <leader>zm (where <leader> == <Space>)
fn add_special_vim_map_base(context: &mut Context, params: [&str; 3], map_type: &str) {
    let map_keys_after_leader = params[0];
    let map_end = params[1];
    let map_comment = params[2];

    context.files.appendln(
        &context.system.get_home_path(".vimrc"),
        format!("{map_type} <leader>zm{map_keys_after_leader} {map_end}",).as_str(),
    );

    context.files.appendln(
        &context
            .system
            .get_home_path(".special-vim-maps-from-provision.txt"),
        format!("<Space>zm{map_keys_after_leader} -- {map_comment}").as_str(),
    );
}

pub fn add_special_vim_map(context: &mut Context, params: [&str; 3]) {
    add_special_vim_map_base(context, params, "nnoremap");
}

pub fn add_special_vim_map_re(context: &mut Context, params: [&str; 3]) {
    add_special_vim_map_base(context, params, "nmap");
}

// https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
pub fn update_vim_colors_theme(context: &mut Context) {
    context
        .files
        .replace(&context.system.get_home_path(".vimrc"), "syntax off", "");

    if context.config.theme == Theme::Light {
        return;
    }

    if Config::has_config_file(&context.system, ".config/vim-theme") {
        return;
    } else {
        context.files.appendln(
            &context.system.get_home_path(".vimrc"),
            "so ~/.vim/colors.vim",
        );
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

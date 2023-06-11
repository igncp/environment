use super::system::System;

#[derive(PartialEq)]
pub enum Theme {
    #[cfg(target_family = "unix")]
    Light,
    Dark,
}

pub struct Config {
    pub netcat_clipboard: bool,
    pub theme: Theme,
    pub without_coc_eslint: bool,
}

impl Config {
    pub fn new(system: &System) -> Self {
        Self {
            netcat_clipboard: Self::has_config_file(system, "netcat-clipboard"),
            theme: Theme::Dark,
            without_coc_eslint: Self::has_config_file(system, "without-coc-eslint"),
        }
    }

    pub fn get_config_file_path(system: &System, file_name: &str) -> String {
        system.get_home_path(&format!(
            "development/environment/project/.config/{file_name}"
        ))
    }

    pub fn has_config_file(system: &System, file_name: &str) -> bool {
        let path = Self::get_config_file_path(system, file_name);

        std::path::Path::new(&path).exists()
    }
}

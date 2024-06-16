use std::collections::HashMap;

pub trait IConfig {
    fn get_all_possible(&self) -> &Vec<String>;
    fn get_config_content(&self, config_item: &str) -> Option<&String>;
    fn get_config_metadata(&self, config_item: &str) -> Option<String>;
    fn get_default_values(&self) -> HashMap<String, String>;
    fn is_config_enabled(&self, config_item: &str) -> bool;
    fn toggle_item(&mut self, config_item: &str, force: Option<bool>);
}

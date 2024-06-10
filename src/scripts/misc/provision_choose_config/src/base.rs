use std::collections::{HashMap, HashSet};

pub trait IConfig {
    fn get_config_file_path(&self, config_item: &str) -> String;
    fn get_enable_command(&self, config_item: &str) -> String;
    fn get_disable_command(&self, config_item: &str) -> String;
    fn get_existing(&self) -> HashSet<String>;
    fn get_content(&self, config: &HashSet<String>) -> HashMap<String, String>;
    fn get_all_possible(&self) -> Vec<String>;
    fn get_default_values(&self) -> HashMap<String, String>;
}

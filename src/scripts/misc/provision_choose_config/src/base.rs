use std::collections::HashMap;

pub type ConfigItemId = String;

#[derive(Clone, Debug)]
pub enum ConfigItemType {
    SimpleFile,
    ValueForFile { file: String, key: String },
}

#[derive(Clone, Debug)]
pub struct ConfigItem {
    pub id: ConfigItemId,
    pub item_type: ConfigItemType,
}

pub trait IConfig {
    fn get_all_possible(&self) -> &Vec<ConfigItem>;
    fn get_config_content(&self, config_item: &str) -> Option<&String>;
    fn get_config_metadata(&self, config_item: &str) -> Option<String>;
    fn get_default_values(&self) -> HashMap<String, String>;
    fn is_config_enabled(&self, config_name: &ConfigItemId) -> bool;
    fn toggle_item(&mut self, config_name: &ConfigItemId, force: Option<bool>);
}

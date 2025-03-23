use crate::base::IConfig;
use std::io::Write;
use std::{
    collections::{HashMap, HashSet},
    fs::File,
};

fn get_all_items() -> Vec<String> {
    let possible_config_rust = std::process::Command::new("bash")
        .arg("-c")
        .arg(r#"grep --no-file -rEo '".config/([_a-zA-Z0-9-])*"' ~/development/environment | sort | uniq"#)
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace(".config/", ""))
        .collect::<Vec<String>>();

    let possible_config_bash = std::process::Command::new("bash")
        .arg("-c")
        .arg(
            r#"grep --no-file -rEo 'PROVISION_CONFIG[^ ]* ' ~/development/environment/src | sort | uniq"#,
        )
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace("PROVISION_CONFIG", ""))
        .collect::<Vec<String>>();

    let possible_config_lua = std::process::Command::new("bash")
        .arg("-c")
        .arg(
            r#"grep --no-file -rEo "(get_config_file_path|has_config)\([^a-z][a-z0-9-]*[^a-z]\)" ~/development/environment/src | sort | uniq"#,
        )
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace("get_config_file_path", ""))
        .map(|x| x.replace("has_config", ""))
        .collect::<Vec<String>>();

    let possible_config_nix = std::process::Command::new("bash")
        .arg("-c")
        .arg(
            r#"grep --no-file -rEo 'base.config \+ "[/a-z0-9-]*"' ~/development/environment/src/nix | sort | uniq"#,
        )
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace("base_config +", ""))
        .map(|x| x.replace("base-config +", ""))
        .collect::<Vec<String>>();

    let mut all_possible_config = possible_config_rust
        .iter()
        .chain(possible_config_bash.iter())
        .chain(possible_config_lua.iter())
        .chain(possible_config_nix.iter())
        .map(|x| x.replace(&['(', ')', '"', '\'', '/', ','][..], ""))
        .map(|x| x.replace("[^", ""))
        .map(|x| x.trim().to_string())
        .filter(|x| !x.is_empty())
        .collect::<Vec<String>>();

    all_possible_config.sort();
    all_possible_config.dedup();

    all_possible_config
}

#[derive(Debug)]
pub struct FileConfig {
    config_dir: String,
    all_items: Vec<String>,
    config_content: HashMap<String, String>,
    config_enabled: HashSet<String>,
}

impl FileConfig {
    pub fn new() -> Self {
        let home_dir = std::env::var("HOME").expect("No home dir found");
        let all_items = get_all_items();

        let config_enabled = HashSet::new();
        let config_content = HashMap::new();

        let mut config = Self {
            all_items,
            config_content,
            config_dir: home_dir + "/development/environment/project/.config",
            config_enabled,
        };

        let existing_config = config.get_existing();
        let existing_files_content = config.get_content(&existing_config);

        config.all_items.iter().for_each(|x| {
            if existing_config.contains(x) {
                config.config_enabled.insert(x.to_string());
                config
                    .config_content
                    .insert(x.to_string(), existing_files_content[x].clone());
            }
        });

        config
    }

    fn get_content(&self, config: &HashSet<String>) -> HashMap<String, String> {
        let config_dir = self.get_config_dir();

        config
            .iter()
            .map(|x| {
                let file_dir = format!("{config_dir}/{x}");
                let content = std::fs::read_to_string(file_dir).unwrap_or_default();
                let content = content.replace('\n', "");

                (x.to_string(), content)
            })
            .collect()
    }

    fn get_config_dir(&self) -> &String {
        &self.config_dir
    }

    fn get_config_file_path(&self, config_item: &str) -> String {
        let config_dir = self.get_config_dir();

        format!("{config_dir}/{config_item}")
    }

    fn get_existing(&self) -> HashSet<String> {
        let config_dir = self.get_config_dir();

        std::fs::read_dir(config_dir)
            .expect("Unable to read config dir")
            .map(|x| x.unwrap().file_name().to_str().unwrap().to_string())
            .collect::<std::collections::HashSet<String>>()
    }

    pub fn get_enable_command(&self, config_item: &str) -> String {
        let file_path = self.get_config_file_path(config_item);

        format!("touch {file_path}")
    }

    pub fn get_disable_command(&self, config_item: &str) -> String {
        let file_path = self.get_config_file_path(config_item);

        format!("rm {file_path}")
    }

    fn enable_item(&mut self, config_item: &str) {
        let default_values = self.get_default_values();
        let empty_string = "".to_string();
        let default_value = default_values.get(config_item).unwrap_or(&empty_string);

        let file_path = self.get_config_file_path(config_item);
        std::fs::write(file_path, default_value).expect("Unable to write file");

        if default_value.is_empty() {
            self.config_content.remove(config_item);
        } else {
            self.config_content
                .insert(config_item.to_string(), default_value.clone());
        };

        self.config_enabled.insert(config_item.to_string());
    }

    fn disable_item(&mut self, config_item: &str) {
        let file_path = self.get_config_file_path(config_item);
        std::fs::remove_file(file_path).unwrap_or_default();
        self.config_content.remove(config_item);

        self.config_enabled.remove(config_item);
    }

    pub fn run_fzf_cmd(&self) {
        let file_content = self
            .get_all_possible()
            .iter()
            .map(|item| {
                let is_enabled = self.is_config_enabled(item);

                if is_enabled {
                    return self.get_disable_command(item);
                } else {
                    return self.get_enable_command(item);
                }
            })
            .collect::<Vec<String>>()
            .join("\n");

        let file_path = "/tmp/provision_choose_config";
        let mut file = File::create(file_path).expect("Unable to create file");
        file.write_all(file_content.as_bytes())
            .expect("Unable to write data");

        std::process::Command::new("bash")
            .arg("-c")
            .arg(format!("cat {file_path} | fzf | sh"))
            .status()
            .expect("Failed to execute command");
    }
}

impl IConfig for FileConfig {
    fn get_all_possible(&self) -> &Vec<String> {
        &self.all_items
    }

    fn get_config_content(&self, config_item: &str) -> Option<&String> {
        self.config_content.get(config_item)
    }

    fn is_config_enabled(&self, config_item: &str) -> bool {
        self.config_enabled.contains(config_item)
    }

    fn get_default_values(&self) -> HashMap<String, String> {
        let mut hash_map = HashMap::new();

        hash_map.insert("vpn_check".to_string(), "yes".to_string());
        hash_map.insert("ssh-notice-color".to_string(), "cyan".to_string());
        hash_map.insert("theme".to_string(), "dark".to_string());
        hash_map.insert("vim-theme".to_string(), "iceberg".to_string());

        hash_map
    }

    fn toggle_item(&mut self, config_item: &str, force: Option<bool>) {
        if self.is_config_enabled(config_item) {
            if let Some(force) = force {
                if force {
                    return;
                }
            }

            self.disable_item(config_item);
        } else {
            if let Some(force) = force {
                if !force {
                    return;
                }
            }

            self.enable_item(config_item);
        }
    }

    fn get_config_metadata(&self, config_item: &str) -> Option<String> {
        let file_created = std::fs::metadata(self.get_config_file_path(config_item));

        if let Ok(file_created) = file_created {
            let created = file_created.created().unwrap();
            let created = created.duration_since(std::time::UNIX_EPOCH).unwrap();

            Some(format!("Created: {:?}", created).to_string())
        } else {
            None
        }
    }
}

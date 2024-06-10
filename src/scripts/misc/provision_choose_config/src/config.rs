use crate::base::IConfig;
use std::collections::{HashMap, HashSet};

pub struct Config {
    config_dir: String,
}

impl Config {
    pub fn new() -> Self {
        let home_dir = std::env::var("HOME").expect("No home dir found");

        Config {
            config_dir: home_dir + "/development/environment/project/.config",
        }
    }

    fn get_config_dir(&self) -> String {
        self.config_dir.clone()
    }
}

impl IConfig for Config {
    fn get_config_file_path(&self, config_item: &str) -> String {
        let config_dir = self.get_config_dir();

        format!("{config_dir}/{config_item}")
    }

    fn get_enable_command(&self, config_item: &str) -> String {
        let file_path = self.get_config_file_path(config_item);

        format!("touch {file_path}")
    }

    fn get_disable_command(&self, config_item: &str) -> String {
        let file_path = self.get_config_file_path(config_item);

        format!("rm {file_path}")
    }

    fn get_existing(&self) -> HashSet<String> {
        let config_dir = self.get_config_dir();

        std::fs::read_dir(config_dir.clone())
            .expect("Unable to read config dir")
            .map(|x| x.unwrap().file_name().to_str().unwrap().to_string())
            .collect::<std::collections::HashSet<String>>()
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

    fn get_all_possible(&self) -> Vec<String> {
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
            r#"grep --no-file -rEo 'base_config \+ "[/a-z0-9-]*"' ~/development/environment/nix | sort | uniq"#,
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

    fn get_default_values(&self) -> HashMap<String, String> {
        let mut hash_map = HashMap::new();

        hash_map.insert("vpn_check".to_string(), "yes".to_string());
        hash_map.insert("ssh-notice-color".to_string(), "cyan".to_string());
        hash_map.insert("theme".to_string(), "dark".to_string());
        hash_map.insert("vim-theme".to_string(), "iceberg".to_string());

        hash_map
    }
}

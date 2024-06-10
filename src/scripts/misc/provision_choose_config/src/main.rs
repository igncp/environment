use app::App;
use base::IConfig;
use clap::Command;
use config::Config;
use std::io::Write;
use std::{error::Error, fs::File};

mod app;
mod base;
mod config;
mod ui;

// This has been extended from: https://github.com/fdehau/tui-rs/blob/master/Cargo.toml
fn main() -> Result<(), Box<dyn Error>> {
    let matches = Command::new("provision_choose_config")
        .version("1.0.0")
        .about("Handle provision configuration")
        .subcommand(Command::new("fzf").about("Instead of the ncurses gui, it pipes to fzf and sh"))
        .get_matches();

    let config = Config::new();
    let app = App::new(&config);

    if matches.subcommand_matches("fzf").is_some() {
        let mut lines: Vec<String> = vec![];

        for item in app.items_state.items.iter() {
            let is_enabled = app.config_enabled.contains(item);

            if is_enabled {
                lines.push(config.get_disable_command(item));
            } else {
                lines.push(config.get_enable_command(item));
            }
        }

        let file_path = "/tmp/provision_choose_config";
        let mut file = File::create(file_path).expect("Unable to create file");
        file.write_all(lines.join("\n").as_bytes())
            .expect("Unable to write data");

        std::process::Command::new("bash")
            .arg("-c")
            .arg(format!("cat {file_path} | fzf | sh"))
            .status()
            .expect("Failed to execute command");

        return Ok(());
    }

    App::run(app)
}

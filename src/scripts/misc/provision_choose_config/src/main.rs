use app::App;
use clap::Command;
use file_config::FileConfig;
use std::error::Error;

mod app;
mod base;
mod file_config;
mod ui;

fn main() -> Result<(), Box<dyn Error>> {
    let matches = Command::new("provision_choose_config")
        .version("1.0.0")
        .about("Handle provision configuration")
        .subcommand(Command::new("fzf").about("Instead of the ncurses gui, it pipes to fzf and sh"))
        .get_matches();

    let mut config = FileConfig::new();
    let mut app = App::new(&mut config);

    if matches.subcommand_matches("fzf").is_some() {
        config.run_fzf_cmd();

        return Ok(());
    }

    app.run()
}

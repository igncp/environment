use std::process;

use clap::{Arg, Command};
use http_client::DelugeHttpClient;

mod http_client;

fn run_bash_command(command: &str) {
    let full_cmd = format!("set -e\n{}", command);
    let output = std::process::Command::new("bash")
        .arg("-c")
        .arg(&full_cmd)
        .status()
        .expect("failed to execute process");

    if !output.success() {
        println!("Command '{}' failed", command);
        process::exit(1);
    }
}

#[tokio::main]
async fn main() {
    let matches = Command::new("deluge")
        .version("1.0.0")
        .about("Utilities for using deluge")
        .subcommand(Command::new("info").about("Lists the existing torrents"))
        .subcommand(Command::new("down").about("Stops docker compose (but not the VPN)"))
        .subcommand(
            Command::new("up").about("Starts docker compose in daemon mode (but not the VPN)"),
        )
        .subcommand(
            Command::new("rm")
                .arg(Arg::new("torrent_id").required(true))
                .about("Remove a torrent by id"),
        )
        .subcommand(
            Command::new("add")
                .arg(Arg::new("magnet_link").required(true))
                .about("Adds a new torrent by using a magent link"),
        )
        .subcommand(Command::new("run").about("Starts the VPN and docker"))
        .arg_required_else_help(true)
        .get_matches();

    if let Some(_matches) = matches.subcommand_matches("info") {
        let torrent_list = DelugeHttpClient::new().get_torrents().await;

        if torrent_list.result.torrents.is_empty() {
            println!("No torrents");
            return;
        }

        for (torrent_id, torrent) in torrent_list.result.torrents.iter() {
            println!(
                "- [{}]: '{}': {}%",
                torrent_id, torrent.name, torrent.progress
            );
        }
    } else if let Some(matches) = matches.subcommand_matches("rm") {
        let torrent_id: &String = matches.get_one::<String>("torrent_id").unwrap();

        let success_removal = DelugeHttpClient::new()
            .remove_torrent(torrent_id.clone())
            .await;

        if success_removal {
            println!("Removed torrent {}", torrent_id);
        } else {
            println!("Failed to remove torrent {}", torrent_id);
        }
    } else if let Some(matches) = matches.subcommand_matches("add") {
        let magnet_link: &String = matches.get_one::<String>("magnet_link").unwrap();

        let success = DelugeHttpClient::new()
            .add_torrent(magnet_link.clone())
            .await;

        if success {
            println!("Torrent added");
        } else {
            println!("Failed to add torrent");
        }
    } else if let Some(_matches) = matches.subcommand_matches("down") {
        run_bash_command("docker compose down");
        println!("Stopped docker compose");
    } else if let Some(_matches) = matches.subcommand_matches("up") {
        run_bash_command("docker compose up -d");
        println!("Started docker compose");
    } else if let Some(_matches) = matches.subcommand_matches("run") {
        run_bash_command(
            r###"
docker compose up -d

(cd ~/vpn && bash run.sh)
"###,
        );
    }
}

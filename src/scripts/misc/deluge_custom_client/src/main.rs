use clap::{Arg, Command};
use controller::Controller;

mod controller;
mod http_client;

#[tokio::main]
async fn main() {
    let matches = Command::new("deluge")
        .version("1.0.0")
        .about("Utilities for using deluge")
        .subcommand(
            Command::new("info")
                .about("Lists the existing torrents")
                .arg(
                    Arg::new("watch")
                        .short('w')
                        .long("watch")
                        .help("Watches the torrents and updates the info")
                        .required(false)
                        .action(clap::ArgAction::SetTrue),
                )
                .arg(
                    Arg::new("id")
                        .short('i')
                        .long("id")
                        .help("Displays the torrent id")
                        .required(false)
                        .action(clap::ArgAction::SetTrue),
                )
                .arg(
                    Arg::new("download_rate")
                        .short('d')
                        .long("download-rate")
                        .help("Displays the download rate for all torrents")
                        .required(false)
                        .action(clap::ArgAction::SetTrue),
                ),
        )
        .subcommand(Command::new("stop").about("Stops docker and/or the VPN"))
        .subcommand(Command::new("init").about("Initialise the deluge dir"))
        .subcommand(
            Command::new("rm")
                .arg(Arg::new("torrent_id").required(false))
                .arg(
                    Arg::new("finished")
                        .short('f')
                        .long_help("Checks that the torrent(s) is finished. If no torrent id is provided, all finished torrents will be removed")
                        .long("finished")
                        .action(clap::ArgAction::SetTrue),
                )
                .about("Remove a torrent by id or by progress"),
        )
        .subcommand(
            Command::new("add")
                .arg(Arg::new("magnet_link").required(true))
                .about("Adds a new torrent by using a magent link"),
        )
        .subcommand(
            Command::new("daemon")
                .about("Interacts with the deluge daemon")
                .subcommand(
                    Command::new("version").about("Gets the version of the deluge daemon")
                )
                .subcommand(
                    Command::new("methods").about("Prints the available methods for RPC")
                ),
        )
        .subcommand(
            Command::new("config")
                .about("Handles deluge config")
                .subcommand(
                    Command::new("get").about("Prints the existing config object (to use with `jq`)")
                )
                .subcommand(
                    Command::new("ip").about("Prints the external IP")
                )
        )
        .subcommand(Command::new("run").about("Starts the VPN and docker"))
        .arg_required_else_help(true)
        .get_matches();

    if let Some(matches) = matches.subcommand_matches("info") {
        let is_watch = matches.get_flag("watch");
        let is_id = matches.get_flag("id");
        let is_download_rate = matches.get_flag("download_rate");

        Controller::display_info(is_watch, is_id, is_download_rate).await;
    } else if let Some(matches) = matches.subcommand_matches("rm") {
        let torrent_id = matches.get_one::<String>("torrent_id");
        let is_finished = matches.get_flag("finished");

        Controller::remove_torrents(torrent_id, is_finished).await;
    } else if let Some(matches) = matches.subcommand_matches("add") {
        let magnet_link: &String = matches.get_one::<String>("magnet_link").unwrap();

        Controller::add_torrent(magnet_link.clone()).await;
    } else if let Some(_matches) = matches.subcommand_matches("stop") {
        Controller::stop_all();
    } else if let Some(_matches) = matches.subcommand_matches("run") {
        Controller::run_all();
    } else if let Some(matches) = matches.subcommand_matches("daemon") {
        if let Some(_matches) = matches.subcommand_matches("version") {
            Controller::get_daemon_version().await;
        } else if let Some(_matches) = matches.subcommand_matches("methods") {
            Controller::get_daemon_method_list().await;
        }
    } else if let Some(matches) = matches.subcommand_matches("config") {
        if let Some(_matches) = matches.subcommand_matches("get") {
            Controller::get_config().await;
        } else if let Some(_matches) = matches.subcommand_matches("ip") {
            Controller::get_external_ip().await;
        }
    } else if matches.subcommand_matches("init").is_some() {
        Controller::init().await;
    }
}

use std::process;

use crate::http_client::DelugeHttpClient;

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

pub struct Controller;

impl Controller {
    pub async fn display_info(is_watch: bool) {
        let mut client = DelugeHttpClient::new();

        loop {
            let torrent_list = client.get_torrents().await;
            if torrent_list.torrents.is_empty() {
                println!("No torrents");
            }

            for (torrent_id, torrent) in torrent_list.torrents.iter() {
                println!(
                    "- [{}]: '{}': {:.1}%",
                    torrent_id, torrent.name, torrent.progress
                );
            }

            if !is_watch || torrent_list.torrents.len() > 1 {
                return;
            }

            tokio::time::sleep(std::time::Duration::from_millis(500)).await;
            // Move cursor up one line
            print!("\x1b[1A");
            print!("\r");
        }
    }

    pub async fn remove_torrents(torrent_id: Option<&String>, is_finished: bool) {
        let mut deluge_client = DelugeHttpClient::new();

        fn print_torrent_removal(success_removal: bool, torrent_id: &str) {
            if success_removal {
                println!("Removed torrent {}", torrent_id);
            } else {
                println!("Failed to remove torrent {}", torrent_id);
            }
        }

        if !is_finished && torrent_id.is_some() {
            let torrent_id = torrent_id.unwrap();
            let success_removal = deluge_client.remove_torrent(torrent_id.to_string()).await;

            print_torrent_removal(success_removal, torrent_id);
        } else if is_finished {
            let torrent_list = DelugeHttpClient::new().get_torrents().await;

            if torrent_list.torrents.is_empty() {
                println!("No torrents to remove");

                if torrent_id.is_some() {
                    process::exit(1);
                }
                return;
            }

            let mut torrents_removed = 0;

            for (info_torrent_id, torrent) in torrent_list.torrents.iter() {
                if torrent.progress == 100.0 {
                    if torrent_id.is_some() && torrent_id.unwrap() != info_torrent_id {
                        continue;
                    }

                    let success_removal =
                        deluge_client.remove_torrent(info_torrent_id.clone()).await;

                    torrents_removed += if success_removal { 1 } else { 0 };

                    print_torrent_removal(success_removal, info_torrent_id);
                }
            }

            if torrents_removed == 0 {
                println!("No torrents removed");
                if torrent_id.is_some() {
                    process::exit(1);
                }
                return;
            }
        } else {
            println!("Please provide a torrent id or use the --finished flag");
            process::exit(1);
        }
    }

    pub async fn add_torrent(magnet_link: String) {
        let success = DelugeHttpClient::new().add_torrent(magnet_link).await;

        if success {
            println!("Torrent added");
        } else {
            println!("Failed to add torrent");
        }
    }

    pub fn stop_all() {
        run_bash_command(
            r###"
docker-compose down || true
sudo bash -c "killall openvpn || true" > /dev/null 2>&1
"###,
        );
        println!("Stopping finished correctly");
    }

    pub fn run_all() {
        run_bash_command(
            r###"
docker-compose up -d

(cd ~/vpn && bash run.sh)
"###,
        );
    }

    pub async fn get_daemon_version() {
        let version = DelugeHttpClient::new().get_daemon_version().await;

        println!("Deluge daemon version: {}", version);
    }

    pub async fn get_daemon_method_list() {
        let methods = DelugeHttpClient::new().get_daemon_method_list().await;

        println!("The available methods for using in RPC:");
        for method in methods {
            println!("- {}", method);
        }
    }

    pub async fn get_config() {
        let config = DelugeHttpClient::new().get_config().await;

        println!("{config}");
    }

    pub async fn get_external_ip() {
        let ip = DelugeHttpClient::new().get_external_ip().await;

        println!("The external IP: {ip}");
    }
}

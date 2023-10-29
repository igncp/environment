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
    pub async fn display_info(is_watch: bool, is_id: bool, is_download_rate: bool) {
        let mut client = DelugeHttpClient::new();

        loop {
            let torrent_list = client.get_torrents().await;
            if torrent_list.torrents.is_empty() {
                println!("No torrents");
            }

            let download_rate_str =
                format!("{:.1} MB/s", torrent_list.stats.get_download_rate_mb());

            let total_torrents = torrent_list.torrents.len();

            for (torrent_id, torrent) in torrent_list.torrents.iter() {
                let formatted_eta = if torrent.eta == 0 {
                    if torrent.progress == 100.0 {
                        "Done".to_string()
                    } else {
                        "∞".to_string()
                    }
                } else {
                    let eta = chrono::Duration::seconds(torrent.eta as i64);
                    let eta = chrono_humanize::HumanTime::from(eta);
                    eta.to_string()
                };
                let id_str = if is_id {
                    format!("[{}] ", torrent_id)
                } else {
                    "".to_string()
                };
                let download_rate_str = if is_download_rate && total_torrents == 1 {
                    format!(": {}", download_rate_str)
                } else {
                    "".to_string()
                };
                println!(
                    "- {}'{}': {:.1}% - {}{}",
                    id_str, torrent.name, torrent.progress, formatted_eta, download_rate_str
                );
            }

            if is_download_rate && total_torrents > 1 {
                println!("Download rate: {}", download_rate_str);
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
cd ~/misc/deluge
docker compose down || true
sudo bash -c "killall openvpn || true" > /dev/null 2>&1
"###,
        );
        println!("Stopping finished correctly");
    }

    pub fn run_all() {
        run_bash_command(
            r###"
cd ~/misc/deluge

RUNNING_VPN=$(ps aux | grep openvpn | grep -v grep | wc -l)

if [ "$RUNNING_VPN" -gt 0 ]; then
    echo "VPN is already running"
    exit 1
fi

docker compose up -d

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

    pub async fn init() {
        run_bash_command(
            r###"
mkdir -p ~/misc/deluge
cp ~/development/environment/src/scripts/misc/deluge_custom_client/docker-compose.yml \
    ~/misc/deluge
if [ ! -d ~/vpn ]; then
  echo "VPN directory missing in ~/vpn"
  exit 1
fi
"###,
        );

        println!("Initialized correctly, use ~/misc/deluge");
    }
}

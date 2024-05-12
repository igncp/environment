use ncurses::{addstr, mv};

use crate::{
    base::AppErr,
    formatters::format_torrent_eta,
    http_client::{DelugeHttpClient, Torrent},
};

use self::ui::UI;

mod ui;

#[derive(Debug, PartialEq)]
enum StateMode {
    AddTorrent,
    Normal,
    Quit,
}

pub struct Dashboard {
    client: DelugeHttpClient,
    mode: StateMode,
    input: Option<String>,
    ui: UI,
}

impl Dashboard {
    pub fn new() -> Dashboard {
        let client = DelugeHttpClient::new();
        let ui = UI::new();

        Dashboard {
            client,
            input: None,
            mode: StateMode::Normal,
            ui,
        }
    }

    fn prompt_normal(&mut self) {
        let ch = self.ui.add_prompt("[q: quit, a: add]", "");

        if ch == -1 {
            return;
        }

        // Letter q
        if ch == 113 {
            self.close();
            return;
        // Letter a
        } else if ch == 97 {
            self.mode = StateMode::AddTorrent;
        } else if ch > 0 {
            addstr(&format!("Key pressed: {}", ch));
            self.ui.paint();
            std::thread::sleep(std::time::Duration::from_secs(1));
        }
    }

    async fn prompt_add_torrent(&mut self) -> Result<(), AppErr> {
        if self.input.is_none() {
            self.input = Some(String::new());
        }

        let input = self.input.as_ref().unwrap();

        let ch = self.ui.add_prompt("[enter magnet link]", &input);

        if ch == -1 {
            return Ok(());
        }

        if ch == 10 {
            self.client.add_torrent(input.clone()).await?;
            self.mode = StateMode::Normal;
            self.input = None;
        } else {
            self.input = Some(format!("{}{}", input, ch as u8 as char));
        }

        Ok(())
    }

    fn close(&mut self) {
        self.ui.close();
        self.mode = StateMode::Quit;
    }

    async fn display(&mut self) -> Result<(), AppErr> {
        self.ui.sync_dymensions();

        let torrent_list = self.client.get_torrents().await?;

        mv(0, 0);

        addstr("\n");
        addstr(&self.ui.get_centered_str(".. Deluge Dashboard .."));
        addstr("\n\n");

        if torrent_list.torrents.is_empty() {
            addstr("No torrents to display");
            return Ok(());
        }

        addstr("Torrents:\n\n");

        let mut torrents = torrent_list
            .torrents
            .iter()
            .map(|(torrent_id, torrent)| (torrent_id.clone(), torrent.clone()))
            .collect::<Vec<(String, Torrent)>>();

        torrents.sort_by_key(|(torrent_id, _)| torrent_id.clone());

        torrents.iter().for_each(|(torrent_id, torrent)| {
            let formatted_eta = format_torrent_eta(torrent);
            let sliced_id = torrent_id.chars().take(5).collect::<String>();

            addstr(&format!(
                "- [{}]: {}: {}",
                sliced_id, &torrent.name, formatted_eta
            ));
            addstr("\n");
        });

        Ok(())
    }

    pub async fn run(&mut self) -> Result<(), AppErr> {
        self.ui.init();

        loop {
            if let Err(err) = self.display().await {
                self.close();

                return Err(err);
            }

            self.ui.paint();
            if self.mode == StateMode::Normal {
                self.prompt_normal();
            } else if self.mode == StateMode::AddTorrent {
                self.prompt_add_torrent().await?;
            }

            if self.mode == StateMode::Quit {
                break;
            }
        }

        Ok(())
    }
}

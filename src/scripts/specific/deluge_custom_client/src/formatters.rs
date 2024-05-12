use crate::http_client::Torrent;

pub fn format_torrent_eta(torrent: &Torrent) -> String {
    return if torrent.eta == 0 {
        if torrent.progress == 100.0 {
            "Done".to_string()
        } else {
            "∞".to_string()
        }
    } else {
        let eta = chrono::Duration::try_seconds(torrent.eta as i64);
        let eta = chrono_humanize::HumanTime::from(eta.unwrap());
        eta.to_string()
    };
}

use std::{env, io::prelude::*, process};

use log::{info, warn};

pub fn check_host_support() {
    let host = env::consts::OS;
    match host {
        "windows" | "linux" | "macos" => {
            info!("Host {host} is supported")
        }
        other => {
            warn!("Host {other} is not supported");
            process::exit(1);
        }
    }
}

fn save_to_clipboard_common(cmd: &str, content: &str) {
    let mut child = process::Command::new(cmd)
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .spawn()
        .unwrap();

    let child_stdin = child.stdin.as_mut().unwrap();

    let write_result = child_stdin.write_all(content.as_bytes());

    if write_result.is_err() {
        warn!("Failed to save stream into clipboard");
        return;
    }

    let result = child.wait_with_output();

    if result.is_err() {
        warn!("Failed to save stream into clipboard");
        return;
    }

    info!("Saved stream into clipboard");
}

pub fn save_to_clipboard(content: &str) {
    match env::consts::OS {
        "windows" => {
            save_to_clipboard_common("clip", content);
        }
        "linux" => {
            save_to_clipboard_common("xclip", content);
        }
        "macos" => {
            save_to_clipboard_common("pbcopy", content);
        }
        other => {
            panic!("Copy to clipboard is not implemented for {other}");
        }
    }
}

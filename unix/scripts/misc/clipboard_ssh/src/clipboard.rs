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

fn save_to_clipboard_common(cmd: &str, content: &str, args: Vec<&str>) {
    let mut child = process::Command::new(cmd);

    for arg in args {
        child.arg(arg);
    }

    let child = child
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .spawn();

    if child.is_err() {
        warn!("Failed to save stream into clipboard");
        return;
    }

    let mut child = child.unwrap();

    let child_stdin = child.stdin.as_mut();

    if child_stdin.is_none() {
        warn!("Failed to save stream into clipboard");
        return;
    }

    let child_stdin = child_stdin.unwrap();

    let write_result = child_stdin.write_all(content.as_bytes());

    if write_result.is_err() {
        warn!("Failed to save stream into clipboard");
        return;
    }

    if cmd != "xclip" {
        let result = child.wait_with_output();

        if result.is_err() {
            warn!("Failed to save stream into clipboard");
            return;
        }
    }

    info!("Saved stream into clipboard");
}

pub fn save_to_clipboard(content: &str) {
    match env::consts::OS {
        "windows" => {
            save_to_clipboard_common("clip", content, vec![]);
        }
        "linux" => {
            save_to_clipboard_common("xclip", content, vec!["-selection", "clipboard"]);
        }
        "macos" => {
            save_to_clipboard_common("pbcopy", content, vec![]);
        }
        other => {
            panic!("Copy to clipboard is not implemented for {other}");
        }
    }
}

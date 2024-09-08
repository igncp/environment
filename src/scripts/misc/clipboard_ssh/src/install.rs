use std::{env, process};

fn install_linux() {
    let xclip_code = process::Command::new("bash")
        .arg("-c")
        .arg("type -a xclip")
        .stdout(process::Stdio::piped())
        .spawn()
        .unwrap()
        .wait()
        .unwrap()
        .code()
        .unwrap();

    if xclip_code != 0 {
        println!("Missing package: xclip");

        return;
    }

    let exists_code = process::Command::new("systemctl")
        .arg("is-active")
        .arg("service-clipboard-ssh")
        .stdout(process::Stdio::piped())
        .spawn()
        .unwrap()
        .wait()
        .unwrap()
        .code()
        .unwrap();

    if exists_code == 0 {
        println!("Service already installed: service-clipboard-ssh");

        return;
    }

    let mut dir_path = env::var("HOME").unwrap();
    dir_path.push_str("/.config/systemd/user");

    std::fs::create_dir_all(&dir_path).unwrap();

    let file_path = format!("{}{}", dir_path.clone(), "/service-clipboard-ssh.service");

    std::fs::write(
        file_path,
        r###"
[Unit]
Description=Clipboard SSH
After=network.target

[Service]
ExecStart=/usr/bin/bash -c \
    'PATH=$PATH:/home/igncp/.nix-profile/bin /usr/local/bin/environment_scripts/clipboard_ssh host'
Restart=always

[Install]
WantedBy=default.target
"###
        .trim(),
    )
    .unwrap();

    let start_code = process::Command::new("systemctl")
        .arg("--user")
        .arg("enable")
        .arg("--now")
        .arg("service-clipboard-ssh")
        .stdout(process::Stdio::piped())
        .spawn()
        .unwrap()
        .wait()
        .unwrap()
        .code()
        .unwrap();

    if start_code != 0 {
        panic!("Failed to install service: service-clipboard-ssh");
    }

    println!("Service installed: service-clipboard-ssh");
}

fn install_macos() {
    let exists_code = process::Command::new("launchctl")
        .arg("list")
        .arg("service-clipboard-ssh")
        .stdout(process::Stdio::piped())
        .spawn()
        .unwrap()
        .wait()
        .unwrap()
        .code()
        .unwrap();

    if exists_code == 0 {
        println!("Service already installed");

        return;
    }

    let mut file_path = env::var("HOME").unwrap();
    file_path.push_str("/Library/LaunchAgents/service-clipboard-ssh.plist");

    std::fs::write(&file_path, r###"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>service-clipboard-ssh</string>
        <key>ProgramArguments</key>
        <array>
            <string>/usr/local/bin/environment_scripts/clipboard_ssh</string>
            <string>host</string>
        </array>
    <key>KeepAlive</key>
    <true/>
    </dict>
</plist>
"###.trim()).unwrap();

    let start_code = process::Command::new("launchctl")
        .arg("load")
        .arg("-w")
        .arg(file_path)
        .stdout(process::Stdio::piped())
        .spawn()
        .unwrap()
        .wait()
        .unwrap()
        .code()
        .unwrap();

    if start_code != 0 {
        panic!("Failed to install service");
    }

    println!("Service installed");
}

pub fn install() {
    match env::consts::OS {
        "windows" => {
            panic!("Install is not implemented for Windows");
        }
        "linux" => {
            install_linux();
        }
        "macos" => {
            install_macos();
        }
        other => {
            panic!("Copy to clipboard is not implemented for {other}");
        }
    }
}

use std::{env, process};

pub fn install() {
    match env::consts::OS {
        "windows" => {
            panic!("Install is not implemented for Windows");
        }
        "linux" => {
            panic!("Install is not implemented for Linux (yet)");
        }
        "macos" => {
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

            // Write file into "$HOME/foo"
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
        other => {
            panic!("Copy to clipboard is not implemented for {other}");
        }
    }
}

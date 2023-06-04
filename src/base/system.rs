use std::{env, io::Write, process::Command};

use crate::base::system::os_commands::{parse_mac_package, parse_ubuntu_package};

mod os_commands;

#[derive(Debug, PartialEq)]
pub enum OS {
    Windows,
    Linux,
    Mac,
    Other,
}

#[derive(Debug, Clone, PartialEq)]
pub enum LinuxDistro {
    Arch,
    Ubuntu,
    Unknown,
}

#[derive(Debug)]
pub struct System {
    pub arch: String,
    pub home: String,
    pub linux_distro: Option<LinuxDistro>,
    pub node_version: Option<String>,
    pub os: OS,
    pub path: String,
}

impl System {
    pub fn install_system_package(&self, command_name: &str, binary: Option<&str>) {
        let used_binary = match binary {
            Some(b) => b,
            None => command_name,
        };

        if self.find_it(used_binary).is_none() {
            println!("Installing: {}", command_name);
            let status = match self.os {
                OS::Mac => Command::new("brew")
                    .arg("install")
                    .arg(parse_mac_package(command_name))
                    .status()
                    .unwrap(),
                OS::Linux => match self.linux_distro.clone().unwrap() {
                    LinuxDistro::Arch => Command::new("sudo")
                        .arg("pacman")
                        .arg("-S")
                        .arg("--noconfirm")
                        .arg(command_name)
                        .status()
                        .unwrap(),
                    LinuxDistro::Ubuntu => Command::new("sudo")
                        .arg("bash")
                        .arg("-c")
                        .arg(format!(
                            "apt-get install -y {}",
                            parse_ubuntu_package(command_name)
                        ))
                        .status()
                        .unwrap(),
                    _ => panic!("Not implemented"),
                },
                _ => panic!("Not implemented"),
            };

            if !status.success() {
                println!("Failed to install {}", command_name);
                std::process::exit(1);
            }
        }
    }

    pub fn run_bash_command(cmd: &str) {
        let full_cmd = format!("set -e\n{}", cmd);
        let status = Command::new("bash")
            .arg("-c")
            .arg(full_cmd)
            .status()
            .unwrap();

        if !status.success() {
            println!("Failed to run command: {}", cmd);
            std::process::exit(1);
        }
    }

    pub fn get_bash_command_output(cmd: &str) -> String {
        let result = Command::new("bash").arg("-c").arg(cmd).output().unwrap();

        if !result.status.success() {
            println!("Failed to run command: {}", cmd);
            std::process::exit(1);
        }

        String::from_utf8(result.stdout).unwrap()
    }

    pub fn is_mac(&self) -> bool {
        self.os == OS::Mac
    }

    pub fn is_linux(&self) -> bool {
        self.os == OS::Linux
    }

    pub fn is_arm(&self) -> bool {
        self.arch == "aarch64"
    }

    pub fn write_file(&self, file: &str, content: &str) {
        let mut f = std::fs::OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(file)
            .unwrap();

        f.write_all(content.as_bytes()).unwrap();
        f.flush().unwrap();
    }

    pub fn get_home_path(&self, subpath: &str) -> String {
        format!("{}/{}", self.home, subpath)
    }

    pub fn get_has_binary(&self, binary: &str) -> bool {
        self.find_it(binary).is_some()
    }

    fn find_it(&self, exe_name: &str) -> Option<String> {
        env::split_paths(&self.path).find_map(|dir| {
            let full_path = dir.join(exe_name);
            if full_path.is_file() {
                Some(full_path.to_str().unwrap().to_string())
            } else {
                None
            }
        })
    }
}

impl Default for System {
    fn default() -> Self {
        let os = match env::consts::OS {
            "windows" => OS::Windows,
            "linux" => OS::Linux,
            "macos" => OS::Mac,
            _ => OS::Other,
        };

        let linux_distro = match os {
            OS::Linux => {
                let distro = System::get_bash_command_output("cat /etc/os-release | grep ID");
                if distro.contains("arch") {
                    Some(LinuxDistro::Arch)
                } else if distro.contains("ubuntu") {
                    Some(LinuxDistro::Ubuntu)
                } else {
                    Some(LinuxDistro::Unknown)
                }
            }
            _ => None,
        };

        Self {
            arch: env::consts::ARCH.to_string(),
            home: env::var_os("HOME").unwrap().to_str().unwrap().to_string(),
            linux_distro,
            node_version: None,
            os,
            path: env::var_os("PATH").unwrap().to_str().unwrap().to_string(),
        }
    }
}

use std::{env, io::Write, process::Command};

use crate::base::system::os_commands::{
    parse_mac_package, parse_pacman_package, parse_ubuntu_package,
};

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
    NixOS,
    Ubuntu,
    Debian,
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
    pub is_nix_provision: bool,
}

impl System {
    pub fn install_system_package(&self, command_name: &str, binary: Option<&str>) {
        let used_binary = match binary {
            Some(b) => b,
            None => command_name,
        };

        if self.find_it(used_binary).is_none() {
            if self.is_nix_provision {
                println!("Requested to install: {}", used_binary);
                return;
            }
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
                        .arg(parse_pacman_package(command_name))
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
                    LinuxDistro::NixOS | LinuxDistro::Debian => Command::new("echo")
                        .arg(format!("Not running any command"))
                        .status()
                        .unwrap(),
                    other => {
                        let distro = format!("{:?}", other);
                        panic!("Not implemented for {distro}");
                    }
                },
                OS::Windows => Command::new("bash")
                    .arg("-c")
                    .arg(format!("winget install {}", command_name))
                    .status()
                    .unwrap(),
                _ => panic!("Not implemented"),
            };

            if !status.success() {
                println!("Failed to install {}", command_name);
                std::process::exit(1);
            }
        }
    }

    #[cfg(target_family = "unix")]
    pub fn install_with_nix(&self, command_name: &str, binary: Option<&str>) {
        let used_binary = match binary {
            Some(b) => b,
            None => command_name,
        };

        if self.find_it(used_binary).is_none() {
            let status = Command::new("nix-env")
                .arg("-iA")
                .arg(format!("nixpkgs.{}", command_name))
                .status()
                .unwrap();

            if !status.success() {
                println!("Failed to install {}", command_name);
                std::process::exit(1);
            }
        }
    }

    // It expects a bin file for each crate
    #[cfg(target_family = "unix")]
    pub fn install_cargo_crate(&self, crate_name: &str, bin_name: Option<&str>) {
        let bin = bin_name.unwrap_or(crate_name);

        if !std::path::Path::new(&format!("{}/.cargo/bin/{}", self.home, bin)).exists() {
            println!("Installing crate: {}", crate_name);
            System::run_bash_command(&format!("cargo install {crate_name}"));
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

    pub fn is_windows(&self) -> bool {
        self.os == OS::Windows
    }

    pub fn is_linux(&self) -> bool {
        self.os == OS::Linux
    }

    pub fn is_debian(&self) -> bool {
        self.os == OS::Linux && self.linux_distro == Some(LinuxDistro::Debian)
    }

    pub fn is_nixos(&self) -> bool {
        self.os == OS::Linux && self.linux_distro == Some(LinuxDistro::NixOS)
    }

    #[cfg(target_family = "unix")]
    pub fn is_arch(&self) -> bool {
        self.os == OS::Linux && self.linux_distro == Some(LinuxDistro::Arch)
    }

    #[cfg(target_family = "unix")]
    pub fn is_ubuntu(&self) -> bool {
        self.os == OS::Linux && self.linux_distro == Some(LinuxDistro::Ubuntu)
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
        #[cfg(target_family = "unix")]
        return format!("{}/{}", self.home, subpath);

        #[cfg(target_family = "windows")]
        return format!("{}\\{}", self.home, subpath);
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
                } else if distro.contains("nixos") {
                    Some(LinuxDistro::NixOS)
                } else if distro.contains("debian") {
                    Some(LinuxDistro::Debian)
                } else {
                    Some(LinuxDistro::Unknown)
                }
            }
            _ => None,
        };

        #[cfg(target_family = "unix")]
        let home = env::var_os("HOME").unwrap().to_str().unwrap().to_string();
        #[cfg(target_family = "windows")]
        let home = env::var_os("USERPROFILE")
            .unwrap()
            .to_str()
            .unwrap()
            .to_string();

        Self {
            arch: env::consts::ARCH.to_string(),
            home,
            linux_distro,
            node_version: None,
            os,
            path: env::var_os("PATH").unwrap().to_str().unwrap().to_string(),
            is_nix_provision: false,
        }
    }
}

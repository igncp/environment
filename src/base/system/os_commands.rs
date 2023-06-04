pub fn parse_ubuntu_package(orig_command: &str) -> &str {
    match orig_command {
        "ag" => "silversearcher-ag",
        "tigervnc" => "tightvncserver",
        _ => orig_command,
    }
}

pub fn parse_mac_package(orig_command: &str) -> &str {
    match orig_command {
        "taskwarrior" => "taskwarrior-tui",
        _ => orig_command,
    }
}

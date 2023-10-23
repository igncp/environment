pub fn run_bash_command(cmd: &str) {
    let full_cmd = format!("set -e\n{}", cmd);
    let status = std::process::Command::new("bash")
        .arg("-c")
        .arg(full_cmd)
        .status()
        .unwrap();

    if !status.success() {
        println!("Failed to run command: {}", cmd);
        std::process::exit(1);
    }
}

pub fn find_binary(exe_name: &str) -> Option<String> {
    let path = std::env::var_os("PATH")
        .unwrap()
        .to_str()
        .unwrap()
        .to_string();

    std::env::split_paths(&path).find_map(|dir| {
        let full_path = dir.join(exe_name);
        if full_path.is_file() {
            Some(full_path.to_str().unwrap().to_string())
        } else {
            None
        }
    })
}

pub fn select_only_chars(s: String) -> String {
    s.chars()
        .filter(|c| *c == '\n' || (!c.is_ascii() && !c.is_ascii_punctuation()))
        .collect::<String>()
}

pub fn get_dict_path() -> String {
    let home_dir = env!("HOME");
    let dict_path = format!("{home_dir}/misc/rime-cantonese/jyut6ping3.chars.dict.yaml");

    dict_path
}

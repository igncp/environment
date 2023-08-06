use clap::{Arg, Command};
use std::io::Read;

fn run_bash_command(cmd: &str) {
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

fn find_binary(exe_name: &str) -> Option<String> {
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

fn main() {
    let app = Command::new("canto-cli")
        .version("1.0.0")
        .about("Utilities to work with Cantonese in the command line")
        .subcommand(
            Command::new("doctor")
                .about("Checks that all dependencies are present in the current system"),
        )
        .subcommand(
            Command::new("sub")
                .about("Download subtitles from a youtube video (requires yt-dlp)")
                .arg(Arg::new("video_url").required(true)),
        )
        .subcommand(
            Command::new("filter-chars")
                .about("Reads from stdin and keeps only chinese characters"),
        )
        .arg_required_else_help(true);

    let matches = app.clone().get_matches();

    if let Some(matches) = matches.subcommand_matches("sub") {
        let video_url = matches.get_one::<String>("video_url");

        if video_url.is_none() {
            println!("Please provide a video url");
            return;
        }

        let video_url = video_url.unwrap();

        run_bash_command(&format!("yt-dlp --all-subs --skip-download {video_url}"));
        run_bash_command("mv *.vtt subs.vtt");

        println!("Subtitles downloaded into subs.vtt");
    } else if let Some(_) = matches.subcommand_matches("filter-chars") {
        let mut buffer = String::new();
        std::io::stdin().read_to_string(&mut buffer).unwrap();

        let filtered = buffer
            .chars()
            .filter(|c| *c == '\n' || (!c.is_ascii() && !c.is_ascii_punctuation()))
            .collect::<String>();

        println!("{}", filtered);
    } else if let Some(_) = matches.subcommand_matches("doctor") {
        let is_yt_dlp_installed = find_binary("yt-dlp").is_some();

        if is_yt_dlp_installed {
            println!("✅ yt-dlp is installed");
        } else {
            println!("❌ yt-dlp is not installed");
        }
    }
}

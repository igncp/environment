use clap::{Arg, Command};
use controller::{find_binary, get_dict_path};
use std::{collections::HashMap, io::Read};

use crate::controller::{run_bash_command, select_only_chars};

mod controller;

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
            Command::new("jp")
                .about("Add jyutping to text")
                .arg(Arg::new("dict_path").required(false))
                .arg(
                    Arg::new("no-filter")
                        .short('n')
                        .long("no-filter")
                        .required(false)
                        .action(clap::ArgAction::SetTrue),
                ),
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

        let filtered = select_only_chars(buffer);

        println!("{}", filtered);
    } else if let Some(_) = matches.subcommand_matches("jp") {
        let mut buffer = String::new();
        std::io::stdin().read_to_string(&mut buffer).unwrap();
        let no_filter_text = matches.get_one::<String>("no-filter");

        let filtered = if no_filter_text.is_some() {
            select_only_chars(buffer)
        } else {
            buffer
        };

        let home_dir = env!("HOME");
        let dict_path = format!("{home_dir}/misc/rime-cantonese/jyut6ping3.chars.dict.yaml");
        let file_content = std::fs::read_to_string(dict_path).unwrap();
        let mut lines = file_content.lines();
        let start_line = lines.position(|line| line == "...").unwrap() + 1;
        let mut dict_map: HashMap<&str, (String, u32)> = HashMap::new();

        lines.skip(start_line).for_each(|line| {
            let mut parts = line.split_whitespace();

            let key = parts.next().unwrap();
            let value = parts.next().unwrap();
            let perc = parts.next().unwrap_or("100%");
            let perc = if perc == "" { "100%" } else { perc };
            let perc = perc.replace("%", "").parse::<u32>().unwrap_or(0);

            let existing_value = dict_map.get(key);

            if existing_value.is_some() && existing_value.unwrap().1 > perc {
                return;
            }

            dict_map.insert(key, (value.to_string(), perc));
        });

        let full_text: String = filtered
            .split("")
            .map(|c| {
                let jyutping = dict_map.get(&c);
                if jyutping.is_none() {
                    return c.to_string();
                }
                let jyutping = jyutping.unwrap();
                let jyutping = jyutping.0.as_str();
                return format!("{c}[{jyutping}] ");
            })
            .collect::<Vec<String>>()
            .join("")
            .trim()
            .to_string();

        println!("full_text {:?}", full_text);
    } else if let Some(_) = matches.subcommand_matches("doctor") {
        let is_yt_dlp_installed = find_binary("yt-dlp").is_some();
        let dict_path = get_dict_path();

        if is_yt_dlp_installed {
            println!("✅ yt-dlp is installed");
        } else {
            println!("❌ yt-dlp is not installed");
        }

        if std::path::Path::new(&dict_path).exists() {
            println!("✅ the dictionary file exists");
        } else {
            println!("❌ the dictionary file does not exist: {dict_path}");
            println!("   - Clone the repo: https://github.com/rime/rime-cantonese.git");
        }
    }
}

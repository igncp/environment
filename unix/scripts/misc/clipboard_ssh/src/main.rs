use std::io::prelude::*;
use std::io::{self, BufRead};
use std::net::TcpListener;
use std::net::TcpStream;

use chrono::Local;
use clap::{Arg, Command};
use env_logger::Builder;
use log::{info, warn, LevelFilter};

use crate::clipboard::{check_host_support, save_to_clipboard};

const DEFAULT_PORT: u16 = 2030;

mod clipboard;

fn main() {
    Builder::new()
        .format(|buf, record| {
            writeln!(
                buf,
                "{} [{}] - {}",
                Local::now().format("%Y-%m-%dT%H:%M:%S"),
                record.level(),
                record.args()
            )
        })
        .filter(None, LevelFilter::Info)
        .init();

    let mut app = Command::new("clipboard_ssh")
        .version("1.0.0")
        .about("Utilities send data from a remote to the local clipboard (and more) via SSH and TCP sockets")
        .arg(
            Arg::new("port")
                .short('p')
                .long("port")
                .required(false)
                .help(format!("Use a different port (default {DEFAULT_PORT})"))
                .action(clap::ArgAction::Set),
        )
        .subcommand(Command::new("send").about("Sends the data from stdin"))
        .subcommand(Command::new("host").about("Listens for data to add into clipboard"))
        .arg_required_else_help(true);

    let matches = app.clone().get_matches();

    let mut port = DEFAULT_PORT;

    if let Some(c) = matches.get_one::<String>("port") {
        port = c.parse::<u16>().unwrap();
    }

    if matches.subcommand_matches("send").is_some() {
        let stream = TcpStream::connect(format!("localhost:{port}"));

        if stream.is_err() {
            warn!("Failed to connect to the server");
            return;
        }

        let mut stream = stream.unwrap();

        let mut lines: Vec<String> = vec![];
        let stdin = io::stdin();

        for line in stdin.lock().lines() {
            lines.push(line.unwrap());
        }

        let content = lines.join("\n");

        let write = stream.write_all(content.as_bytes());

        if write.is_err() {
            warn!("Failed to send data to the server");
        }
    } else if matches.subcommand_matches("host").is_some() {
        check_host_support();

        fn handle_client(stream: &mut TcpStream) {
            let mut content = vec![];
            content.resize(102400, 0);
            let result = stream.read(&mut content);
            if result.is_err() {
                warn!("Failed to read data from the client");
                return;
            }
            let content = String::from_utf8(content).unwrap();

            save_to_clipboard(&content);
        }

        let listener = TcpListener::bind(format!("localhost:{port}")).unwrap();

        info!("Listening on port {port}...");

        for stream in listener.incoming() {
            if let Ok(mut stream) = stream {
                handle_client(&mut stream);
            } else {
                warn!("Error stream");
            }
        }
    } else {
        println!("No command specified");
        app.print_help().unwrap();
    }
}

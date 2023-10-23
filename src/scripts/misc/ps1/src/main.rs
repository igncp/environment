use std::path::Path;

use chrono::prelude::*;

const ANSI_COLOR_GREEN: &'static str = "\x1b[0;32m";
const ANSI_COLOR_RED: &'static str = "\x1b[0;31m";
const ANSI_COLOR_MAGENTA: &'static str = "\x1b[0;35m";
const ANSI_COLOR_BLUE: &'static str = "\x1b[0;34m";
const ANSI_COLOR_RESET: &'static str = "\x1b[0;0m";

#[derive(Eq, PartialEq, Clone)]
enum Shell {
    Bash,
    Zsh,
}

// https://miro.medium.com/max/4800/1*Q4WxN-bh4Exk8ULhwSexGQ.png
fn translate_color_to_ansi(zsh_color: &str) -> &str {
    match zsh_color {
        "green" => ANSI_COLOR_GREEN,
        "magenta" => ANSI_COLOR_MAGENTA,
        "red" => ANSI_COLOR_RED,
        _ => ANSI_COLOR_RESET,
    }
}

async fn get_tmux_window_index() -> Option<String> {
    let tmux = std::env::var("TMUX").unwrap_or("".to_string());

    if tmux.is_empty() {
        return None;
    }

    let tmux_window_index = tokio::process::Command::new("tmux")
        .arg("display-message")
        .arg("-p")
        .arg("#I")
        .output()
        .await;

    if tmux_window_index.is_err() {
        return None;
    }

    let tmux_window_index = tmux_window_index.unwrap();

    let parsed = tmux_window_index
        .stdout
        .into_iter()
        .map(|x| x as char)
        .collect::<String>()
        .strip_suffix('\n')
        .unwrap()
        .to_string();

    Some(parsed)
}

#[derive(Clone)]
enum TaskResult {
    GitBranch(String),
    SSHNotice(String),
    TmuxPrefix((String, String)),
    Vpn(String),
    Tailscale(String),
}

async fn get_tmux_prefix() -> TaskResult {
    let tmux_window_index = get_tmux_window_index().await;

    let mut tmux_prefix_a = String::new();
    let mut tmux_prefix_b = String::new();

    if let Some(tmux_window_index) = tmux_window_index {
        tmux_prefix_a = tmux_window_index;
    } else {
        tmux_prefix_b = " ·".to_string();
    }

    TaskResult::TmuxPrefix((tmux_prefix_a, tmux_prefix_b))
}

async fn get_ssh_notice(shell: Shell) -> TaskResult {
    let home_path = std::env::var("HOME").unwrap();
    let ssh_client = std::env::var("SSH_CLIENT").unwrap_or("".to_string());
    let ssh_tty = std::env::var("SSH_TTY").unwrap_or("".to_string());
    let ssh_connection = std::env::var("SSH_CONNECTION").unwrap_or("".to_string());

    let ssh_notice_color = tokio::fs::read_to_string(format!(
        "{}{}",
        home_path, "/development/environment/project/.config/ssh-notice-color"
    ))
    .await
    .unwrap_or("cyan".to_string())
    .trim_end()
    .to_string();

    let mut ssh_notice = String::new();

    if !ssh_client.is_empty() || !ssh_tty.is_empty() || !ssh_connection.is_empty() {
        let file_value = tokio::fs::read_to_string(
            home_path + "/development/environment/project/.config/ssh-notice",
        )
        .await;

        if let Ok(file_value) = file_value {
            let file_value = file_value.trim_end().to_string();

            if file_value.is_empty() {
                ssh_notice = " [VM]".to_string();
            } else {
                ssh_notice = format!(" [{file_value}]");
            }
        } else {
            ssh_notice = " [SSH]".to_string();
        }
    }

    let result = if shell == Shell::Zsh {
        format!("%F{{{ssh_notice_color}}}{ssh_notice} %F{{green}}%1d")
    } else {
        let color = translate_color_to_ansi(&ssh_notice_color);
        let current_dir = std::env::current_dir();
        if current_dir.is_err() {
            return TaskResult::SSHNotice("".to_string());
        }
        let current_dir = current_dir.unwrap();
        let current_dir = current_dir.to_str().unwrap().split('/').last().unwrap();
        format!("{color}{ssh_notice} {ANSI_COLOR_GREEN}{current_dir}")
    };

    TaskResult::SSHNotice(result)
}

fn get_time() -> String {
    let dt = Local::now();

    format!("{:0>2}:{:0>2}", dt.hour(), dt.minute())
}

async fn get_git_ps1(shell: Shell) -> TaskResult {
    let result = tokio::process::Command::new("bash")
        .arg("-c")
        .arg(". ~/.git-prompt && __git_ps1")
        .output()
        .await
        .unwrap()
        .stdout
        .into_iter()
        .map(|x| x as char)
        .collect::<String>();

    let result_color = if shell == Shell::Zsh {
        format!("%F{{green}}{result}%F{{reset_color}}")
    } else {
        format!("{ANSI_COLOR_GREEN}{result}{ANSI_COLOR_RESET}")
    };
    TaskResult::GitBranch(result_color)
}

fn get_background_jobs(jobs_args: String) -> Option<String> {
    // The format is Xr/Ys where X is the running number and Y is the suspended number
    let jobs_args = jobs_args.split('/').collect::<Vec<&str>>();
    let running_str = jobs_args.first()?;
    let running_jobs = running_str.replace('r', "").parse::<usize>().ok()?;
    let suspended_str = jobs_args.get(1)?;
    let suspended_jobs = suspended_str.replace('s', "").parse::<usize>().ok()?;
    let jobs = running_jobs + suspended_jobs;

    if jobs == 0 {
        return None;
    }

    Some(format!(" {}", jobs))
}

async fn get_tailscale_status() -> TaskResult {
    let home_path = std::env::var("HOME").unwrap();
    // Added in a variable like this so it can be found in the config script
    let config_file = ".config/ps1-no-tailscale";
    if Path::new(&format!(
        "{home_path}/development/environment/project/{config_file}"
    ))
    .exists()
    {
        return TaskResult::Tailscale("".to_string());
    }

    let tailscale_status = tokio::process::Command::new("bash")
        .arg("-c")
        .arg(
            "tailscale status --peers=false | grep -vqE '(stopped|Logged out)' && echo connected || echo ''",
        )
        .output()
        .await
        .unwrap()
        .stdout
        .into_iter()
        .map(|x| x as char)
        .collect::<String>()
        .replace('\n', "");

    if tailscale_status != "connected" {
        return TaskResult::Tailscale("".to_string());
    }

    TaskResult::Tailscale(" %F{yellow}[TS]%F{reset_color}".to_string())
}

async fn get_vpn() -> TaskResult {
    let home_path = std::env::var("HOME").unwrap();

    let full_content =
        tokio::fs::read_to_string(home_path + "/development/environment/project/.config/vpn_check")
            .await
            .unwrap_or("".to_string());

    let content = full_content
        .clone()
        .strip_suffix('\n')
        .unwrap_or(&full_content)
        .to_string();

    if content != "yes" {
        return TaskResult::Vpn("".to_string());
    }

    let vpn_running = tokio::process::Command::new("bash")
        .arg("-c")
        .arg("ps aux | grep -v grep | grep -q openvpn && echo yes || echo no")
        .output()
        .await
        .unwrap();

    if vpn_running.stdout == b"no\n" {
        return TaskResult::Vpn(" %F{red}NO_VPN%F{reset_color}".to_string());
    }

    TaskResult::Vpn("".to_string())
}

#[tokio::main]
async fn main() {
    let args: Vec<String> = std::env::args().collect();

    let shell = args.get(1).unwrap_or(&"bash".to_string()).to_string();
    let shell = if shell == "bash" {
        Shell::Bash
    } else {
        Shell::Zsh
    };
    let jobs_args = args.get(2).unwrap_or(&"".to_string()).to_string();
    let jobs_prefix = get_background_jobs(jobs_args).unwrap_or("".to_string());
    let is_nix_develop = std::env::var("CD_INTO_NIX").unwrap_or_else(|_| {
        return std::env::var("IN_NIX_SHELL").unwrap_or("0".to_string());
    });

    let tasks: Vec<tokio::task::JoinHandle<TaskResult>> = vec![
        tokio::spawn(get_tmux_prefix()),
        tokio::spawn(get_vpn()),
        tokio::spawn(get_ssh_notice(shell.clone())),
        tokio::spawn(get_git_ps1(shell.clone())),
        tokio::spawn(get_tailscale_status()),
    ];

    let tasks_result = futures::future::join_all(tasks)
        .await
        .into_iter()
        .map(|x| x.unwrap())
        .collect::<Vec<TaskResult>>();

    let (tmux_prefix_a, tmux_prefix_b) = tasks_result
        .clone()
        .into_iter()
        .find_map(|x| match x {
            TaskResult::TmuxPrefix(a) => Some(a),
            _ => None,
        })
        .unwrap();
    let vpn_result = match tasks_result.get(1).unwrap() {
        TaskResult::Vpn(a) => a,
        _ => panic!(""),
    };
    let ssh_notice = match tasks_result.get(2).unwrap() {
        TaskResult::SSHNotice(a) => a,
        _ => panic!(""),
    };
    let git_ps1 = match tasks_result.get(3).unwrap() {
        TaskResult::GitBranch(a) => a,
        _ => panic!(""),
    };
    let tailscale = match tasks_result.get(4).unwrap() {
        TaskResult::Tailscale(a) => a,
        _ => panic!(""),
    };
    let nix_prefix = if is_nix_develop != "0".to_string() {
        " (NIX)"
    } else {
        ""
    };

    if shell.clone() == Shell::Zsh {
        let ps1_start = format!("{tmux_prefix_a}{nix_prefix}{ssh_notice}{vpn_result}{tailscale}");
        let ps1_middle = format!("{git_ps1}{jobs_prefix}");
        let time = get_time();
        let ps1_end = format!("%F{{39}}{}{}%F{{reset_color}}", time, tmux_prefix_b);

        println!("\n\n{}{} {} ", ps1_start, ps1_middle, ps1_end);
    } else {
        let ps1_start = format!("{tmux_prefix_a}{nix_prefix}{ssh_notice}{vpn_result}{tailscale}");
        let ps1_middle = format!("{git_ps1}{jobs_prefix}");
        let time = get_time();
        let ps1_end = format!(
            "{ANSI_COLOR_BLUE}{}{}{ANSI_COLOR_RESET}",
            time, tmux_prefix_b
        );

        println!("\n\n{}{} {} ", ps1_start, ps1_middle, ps1_end);
    }
}

use chrono::prelude::*;

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
        .await
        .unwrap();

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

async fn get_ssh_notice() -> TaskResult {
    let home_path = std::env::var("HOME").unwrap();
    let ssh_client = std::env::var("SSH_CLIENT").unwrap_or("".to_string());
    let ssh_tty = std::env::var("SSH_TTY").unwrap_or("".to_string());
    let ssh_connection = std::env::var("SSH_CONNECTION").unwrap_or("".to_string());

    let ssh_notice_color = tokio::fs::read_to_string(format!(
        "{}{}",
        home_path, "/project/.config/ssh-notice-color"
    ))
    .await
    .unwrap_or("cyan".to_string())
    .trim_end()
    .to_string();

    let mut ssh_notice = String::new();

    if !ssh_client.is_empty() || !ssh_tty.is_empty() || !ssh_connection.is_empty() {
        let file_value = tokio::fs::read_to_string(home_path + "/project/.config/ssh-notice").await;

        if let Ok(file_value) = file_value {
            let file_value = file_value.trim_end().to_string();

            if file_value.is_empty() {
                ssh_notice = "[VM]".to_string();
            } else {
                ssh_notice = format!("[{}]", file_value);
            }
        } else {
            ssh_notice = "[SSH]".to_string();
        }
    }

    let result = format!("%F{{{ssh_notice_color}}}{ssh_notice} %F{{green}}%1d");

    TaskResult::SSHNotice(result)
}

fn get_time() -> String {
    let dt = Local::now();

    format!("{:0>2}:{:0>2}", dt.hour(), dt.minute())
}

async fn get_git_ps1() -> TaskResult {
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

    let result_color = format!("%F{{green}}{result}%F{{reset_color}}");
    TaskResult::GitBranch(result_color)
}

fn get_jobs(jobs_args: String) -> String {
    let jobs = jobs_args.lines().count();

    if jobs == 0 {
        return "".to_string();
    }

    format!(" {}", jobs)
}

async fn get_vpn() -> TaskResult {
    let home_path = std::env::var("HOME").unwrap();

    let full_content = tokio::fs::read_to_string(home_path + "/project/.config/vpn_check")
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

// This should support both bash and zsh. Currently it only supports zsh.
// https://miro.medium.com/max/4800/1*Q4WxN-bh4Exk8ULhwSexGQ.png
#[tokio::main]
async fn main() {
    let args: Vec<String> = std::env::args().collect();

    let jobs_args = args.get(1).unwrap_or(&"".to_string()).to_string();
    let jobs_prefix = get_jobs(jobs_args);

    let tasks: Vec<tokio::task::JoinHandle<TaskResult>> = vec![
        tokio::spawn(get_tmux_prefix()),
        tokio::spawn(get_vpn()),
        tokio::spawn(get_ssh_notice()),
        tokio::spawn(get_git_ps1()),
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

    let ps1_start = format!("{tmux_prefix_a} {ssh_notice}{vpn_result}");
    let ps1_middle = format!("{git_ps1}{jobs_prefix}");
    let time = get_time();
    let ps1_end = format!("%F{{39}}{}{}%F{{reset_color}}", time, tmux_prefix_b);

    println!("\n\n{}{} {} ", ps1_start, ps1_middle, ps1_end);
}

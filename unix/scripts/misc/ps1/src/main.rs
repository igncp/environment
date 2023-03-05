use chrono::prelude::*;

fn get_tmux_window_index() -> Option<String> {
    let tmux = std::env::var("TMUX").unwrap_or("".to_string());

    if tmux.is_empty() {
        return None;
    }

    let tmux_window_index = std::process::Command::new("tmux")
        .arg("display-message")
        .arg("-p")
        .arg("#I")
        .output()
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

fn get_tmux_prefix() -> (String, String) {
    let tmux_window_index = get_tmux_window_index();

    let mut tmux_prefix_a = String::new();
    let mut tmux_prefix_b = String::new();

    if let Some(tmux_window_index) = tmux_window_index {
        tmux_prefix_a = tmux_window_index;
    } else {
        tmux_prefix_b = " ·".to_string();
    }

    (tmux_prefix_a, tmux_prefix_b)
}

fn get_ssh_notice() -> String {
    let home_path = std::env::var("HOME").unwrap();
    let ssh_client = std::env::var("SSH_CLIENT").unwrap_or("".to_string());
    let ssh_tty = std::env::var("SSH_TTY").unwrap_or("".to_string());
    let ssh_connection = std::env::var("SSH_CONNECTION").unwrap_or("".to_string());

    let ssh_notice_color = std::fs::read_to_string(format!(
        "{}{}",
        home_path, "/project/.config/ssh-notice-color"
    ))
    .unwrap_or("cyan".to_string())
    .strip_suffix('\n')
    .unwrap()
    .to_string();

    let mut ssh_notice = String::new();

    if !ssh_client.is_empty() || !ssh_tty.is_empty() || !ssh_connection.is_empty() {
        let file_value = std::fs::read_to_string(home_path + "/project/.config/ssh-notice");

        if let Ok(file_value) = file_value {
            let file_value = file_value.strip_suffix('\n').unwrap().to_string();

            if file_value.is_empty() {
                ssh_notice = "[VM]".to_string();
            } else {
                ssh_notice = format!("[{}]", file_value);
            }
        } else {
            ssh_notice = "[SSH]".to_string();
        }
    }

    format!("%F{{{}}}{} %F{{green}}%1d", ssh_notice_color, ssh_notice)
}

fn get_time() -> String {
    let dt = Local::now();

    format!("{:0>2}:{:0>2}", dt.hour(), dt.minute())
}

fn get_git_ps1() -> String {
    std::process::Command::new("bash")
        .arg("-c")
        .arg(". ~/.git-prompt && __git_ps1")
        .output()
        .unwrap()
        .stdout
        .into_iter()
        .map(|x| x as char)
        .collect::<String>()
}

fn get_jobs(jobs_args: String) -> String {
    let jobs = jobs_args.lines().count();

    if jobs == 0 {
        return "".to_string();
    }

    format!(" {}", jobs)
}

// This should support both bash and zsh. Currently it only supports zsh.
// https://miro.medium.com/max/4800/1*Q4WxN-bh4Exk8ULhwSexGQ.png
fn main() {
    let args: Vec<String> = std::env::args().collect();
    let ssh_notice = get_ssh_notice();
    let git_ps1 = get_git_ps1();
    let (tmux_prefix_a, tmux_prefix_b) = get_tmux_prefix();

    let jobs_args = args.get(1).unwrap_or(&"".to_string()).to_string();
    let jobs_prefix = get_jobs(jobs_args);
    let ps1_middle = format!("{}{}", git_ps1, jobs_prefix);

    let time = get_time();
    let ps1_end = format!("%F{{39}}{}{}%F{{reset_color}}", time, tmux_prefix_b);

    println!(
        "\n\n{} {}{} {} ",
        tmux_prefix_a, ssh_notice, ps1_middle, ps1_end
    );
}

use std::{fs::metadata, process::Command};

/**
 * If the path is absolute, return it. Otherwise, try to find the path relative to the current
 * working directory. If the path is not found, try to find it relative to the parent directory.
 * Repeat this process until the path is found or the parent directory is the root directory.
 */
fn find_correct_path(checked_path: &String) -> Option<String> {
    let is_absolute = checked_path.starts_with('/');
    let mut levels_up = 0;

    loop {
        let mut prefix = "".to_string();
        for _ in 0..levels_up {
            prefix = format!("../{}", prefix);
        }
        let full_path = format!("{}{}", prefix, checked_path);
        let path_metadata = metadata(full_path.clone());

        if path_metadata.is_ok() {
            return Some(full_path);
        }

        if is_absolute || levels_up > 100 {
            return None;
        } else {
            levels_up += 1;
        }
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    let first_path = args.get(1);

    let default_string = ".".to_string();
    let mut resolved_path = first_path.unwrap_or(&default_string).clone();

    if resolved_path.starts_with("a/") || resolved_path.starts_with("b/") {
        println!("Path starts with a/ or b/, removing prefix, asumming it is from a diff");
        resolved_path = String::from(&resolved_path[2..]);
    }

    let correct_path = find_correct_path(&resolved_path);

    let full_path = match correct_path {
        Some(path) => path,
        None => resolved_path.clone(),
    };

    let cmd_args = &["-s", "-c", &format!("tab drop {}", full_path)];

    Command::new("nvr")
        .args(cmd_args)
        .args(if args.len() > 2 { &args[2..] } else { &[] })
        .status()
        .expect("Failed to open file");
}

use std::{fs::metadata, process::Command};

/**
 * If the path is absolute, return it. Otherwise, try to find the path relative to the current
 * working directory. If the path is not found, try to find it relative to the parent directory.
 * Repeat this process until the path is found or the parent directory is the root directory.
 */
fn find_correct_path(checked_path: &String) -> Result<String, String> {
    let is_absolute = checked_path.starts_with('/');
    let has_slash = checked_path.contains('/');
    let mut levels_up = 0;

    loop {
        let mut prefix = "".to_string();
        for _ in 0..levels_up {
            prefix = format!("../{}", prefix);
        }
        let full_path = format!("{}{}", prefix, checked_path);
        let path_metadata = metadata(full_path.clone());

        if path_metadata.is_ok() {
            return Ok(full_path);
        }

        if is_absolute || levels_up > 100 ||
            // When the path doesn't contain any slash, don't try to go up as probably trying to
            // create a new file
            !has_slash
        {
            let err_str = format!("Could not find path: {}", checked_path);
            return Err(err_str);
        } else {
            levels_up += 1;
        }
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    let first_path = args.get(1);

    let default_string = ".".to_string();
    let resolved_path = first_path.unwrap_or(&default_string);
    let correct_path = find_correct_path(resolved_path);

    let editor = std::env::var("EDITOR").unwrap_or("vim".to_string());

    // If the file doesn't exist, create it.
    let final_path = correct_path.unwrap_or(resolved_path.to_string());

    Command::new(editor)
        .arg(final_path)
        .args(if args.len() > 3 { &args[3..] } else { &[] })
        .status()
        .expect("Failed to open file");
}

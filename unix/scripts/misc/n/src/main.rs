use std::{
    fs::metadata,
    process::{self, Command},
};

/**
 * If the path is absolute, return it. Otherwise, try to find the path relative to the current
 * working directory. If the path is not found, try to find it relative to the parent directory.
 * Repeat this process until the path is found or the parent directory is the root directory.
 */
fn find_correct_path(checked_path: &String) -> Result<String, String> {
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
            return Ok(full_path);
        }

        if is_absolute || levels_up > 100 {
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

    if let Err(error) = correct_path {
        println!("{}", error);
        process::exit(1);
    }

    let full_path = correct_path.unwrap();
    let editor = std::env::var("EDITOR").unwrap_or("vim".to_string());

    Command::new(editor)
        .arg(full_path)
        .args(if args.len() > 2 { &args[2..] } else { &[] })
        .status()
        .expect("Failed to open file");
}

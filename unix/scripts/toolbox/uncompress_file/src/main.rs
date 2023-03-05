use skim::prelude::*;

fn main() {
    let files = walkdir::WalkDir::new(".")
        .into_iter()
        .filter_map(|v| v.ok())
        .filter(|v| v.file_type().is_file())
        .map(|x| x.path().to_str().unwrap().to_string())
        .collect::<Vec<_>>()
        .join("\n");

    let options = SkimOptionsBuilder::default().build().unwrap();

    let item_reader = SkimItemReader::default();
    let items = item_reader.of_bufread(std::io::Cursor::new(files));

    let selected_item = Skim::run_with(&options, Some(items))
        .map(|out| out.selected_items)
        .unwrap_or(vec![]);

    if selected_item.is_empty() {
        return;
    }

    let file = selected_item[0].output().to_string();

    if !file.ends_with(".zip") && !file.ends_with(".tar.gz") {
        println!("echo Unknown file type");
        return;
    }

    let directory_output = walkdir::WalkDir::new(".")
        .into_iter()
        .filter_map(|v| v.ok())
        .filter(|v| v.file_type().is_dir())
        .map(|x| x.path().to_str().unwrap().to_string())
        .collect::<Vec<_>>()
        .join("\n");

    let item_reader = SkimItemReader::default();
    let items = item_reader.of_bufread(std::io::Cursor::new(directory_output));

    let selected_item = Skim::run_with(&options, Some(items))
        .map(|out| out.selected_items)
        .unwrap_or(vec![]);

    if selected_item.is_empty() {
        return;
    }

    let directory = selected_item[0].output().to_string();

    if file.ends_with(".zip") {
        println!("unzip {file} -d {directory}");
    } else if file.ends_with(".tar.gz") {
        println!("tar xvzf {file} -C {directory}");
    }
}

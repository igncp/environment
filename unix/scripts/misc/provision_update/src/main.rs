use serde::Deserialize;

const TMP_PROVISION_DIR: &str = "/tmp/provision";
const DIFF_FILE_PATH: &str = "/tmp/diff_provision.sh";

#[derive(Debug, Deserialize)]
struct UpdateConfig {
    #[serde(rename = "PROVISION_DIR")]
    provision_dir: String,
    #[serde(rename = "ENVIRONMENT_DIR")]
    environment_dir: String,
    #[serde(rename = "ITEMS")]
    items: Vec<Vec<String>>,
}

fn main() {
    let home = std::env::var("HOME").unwrap();
    let file_content =
        std::fs::read_to_string(home + "/project/provision/data.updateProvision.json").unwrap();

    let config = serde_json::from_str::<UpdateConfig>(&file_content).unwrap();

    let provision_file_path = format!("{}/provision.sh", &config.provision_dir);
    let mut provision_file_content = std::fs::read_to_string(provision_file_path).unwrap();

    config.items.iter().for_each(|item| {
        let name = &item[0];
        let item_path = &item[1];

        if !item_path.contains(name) {
            println!(
                "Unexpected path, does not contain name: {}, {}",
                name, item_path
            );

            std::process::exit(1);
        }

        let mut to_update_content =
            std::fs::read_to_string(config.environment_dir.clone() + "/" + item_path).unwrap();

        if name == "top" {
            to_update_content = to_update_content.replace("#!/usr/bin/env bash\n\n", "");
        }

        let regex_str = ["(?s)# ", name, " START(.|\n)*# ", name, " END"].join("");
        let regex = regex::Regex::new(&regex_str).unwrap();

        if !regex.is_match(&provision_file_content) {
            let previous_item_name = &config.items[config
                .items
                .iter()
                .position(|x| &x[0].to_string() == name)
                .unwrap()
                - 1][0];
            let previous_regex_str = ["# ", previous_item_name, " END"].join("");

            provision_file_content = provision_file_content.replace(
                &previous_regex_str,
                &format!("{}\n\n{}", previous_regex_str, to_update_content.trim()),
            );
        } else {
            let regex = regex::Regex::new(&regex_str).unwrap();
            let replace_str = "+".repeat(20);

            // Can't replace directly because the result has special characters that would be used
            // as replacement groups
            provision_file_content = regex
                .replace(&provision_file_content, &replace_str)
                .replace(&replace_str, to_update_content.trim());
        }

        println!("Updated: {}", name);
    });

    let result_provision = format!("{}/provision.sh", TMP_PROVISION_DIR);

    if std::path::Path::new(TMP_PROVISION_DIR).exists() {
        std::fs::remove_dir_all(TMP_PROVISION_DIR).unwrap();
    }
    std::fs::create_dir(TMP_PROVISION_DIR).unwrap();

    std::fs::write(result_provision, provision_file_content).unwrap();

    let configuration_files =
        std::fs::read_dir(format!("{}/unix/config-files", config.environment_dir))
            .unwrap()
            .map(|res| res.map(|e| e.path()))
            .collect::<Result<Vec<_>, std::io::Error>>()
            .unwrap()
            .iter()
            .map(|path| path.file_name().unwrap().to_str().unwrap().to_string())
            .filter(|file| !file.contains("data.updateProvision.js"))
            .collect::<Vec<String>>();

    std::fs::read_dir(&config.provision_dir)
        .unwrap()
        .map(|res| res.map(|e| e.path()))
        .collect::<Result<Vec<_>, std::io::Error>>()
        .unwrap()
        .iter()
        .filter(|path| {
            let file_name = path.file_name().unwrap().to_str().unwrap();

            configuration_files.iter().any(|file| file_name == file)
        })
        .for_each(|path| {
            let file_name = path.file_name().unwrap().to_str().unwrap();

            std::fs::copy(
                format!("{}/unix/config-files/{}", config.environment_dir, file_name),
                format!("{}/{}", TMP_PROVISION_DIR, file_name),
            )
            .unwrap();
        });

    let common_beginning = "diff --color=always -r ";
    let common_ending = " | sed 's/\\x1b[[36;]*m//g' >> /tmp/_diff-output.txt";

    let get_scripts_diff = |dir: &str| -> String {
        let replacement = format!("/scripts/{}", dir);

        format!(
            "{}{} {}/unix/scripts/{}{}",
            common_beginning,
            config.provision_dir.replace("/provision", &replacement),
            config.environment_dir,
            dir,
            common_ending
        )
    };

    let first_command = "echo > /tmp/_diff-output.txt";
    let second_command = [
        common_beginning,
        "-x data.updateProvision.json ",
        &config.provision_dir,
        " ",
        TMP_PROVISION_DIR,
        common_ending,
    ]
    .join(" ");

    let last_commands = [
        get_scripts_diff("toolbox"),
        get_scripts_diff("ts-morph"),
        get_scripts_diff("misc"),
        "less -R /tmp/_diff-output.txt".to_string(),
    ]
    .join("\n"); // It is important to use -R (and not -r) for diffs
    let diff_command = format!("{}\n{}\n{}", first_command, second_command, last_commands);

    std::fs::write(DIFF_FILE_PATH, diff_command).unwrap();

    println!("Created files in: {}", TMP_PROVISION_DIR);
    println!("Check the diff by: `sh {}`", DIFF_FILE_PATH);
}

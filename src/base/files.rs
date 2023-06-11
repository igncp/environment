use std::collections::HashMap;
use std::io::Write;

pub struct Files {
    pub data: HashMap<String, String>,
}

impl Default for Files {
    fn default() -> Self {
        let data = HashMap::new();

        Self { data }
    }
}

impl Files {
    fn write_file(&self, file: &str, content: &str) {
        let expect_msg = format!("Failed to open file: {}", file);
        let mut f = std::fs::OpenOptions::new()
            .create(true)
            .write(true)
            .truncate(true)
            .open(file)
            .expect(&expect_msg);

        f.write_all(content.as_bytes()).unwrap();
        f.flush().unwrap();
    }

    pub fn append(&mut self, path: &str, content: &str) {
        if self.data.contains_key(path) {
            let mut current_data = self.data.get(path).unwrap().clone();
            current_data.push_str(content);
            self.data.insert(path.to_string(), current_data.to_string());
            self.write_file(path, &current_data);
        } else {
            self.data.insert(path.to_string(), content.to_string());
            self.write_file(path, content);
        }
    }

    pub fn append_json(&mut self, path: &str, content: &str) {
        if self.data.contains_key(path) {
            let mut current_data = self.data.get(path).unwrap().clone();
            current_data = current_data.replace("}\n", ", ");
            current_data.push_str(content);
            current_data.push_str("\n}\n");
            self.data.insert(path.to_string(), current_data.to_string());
            self.write_file(path, &current_data);
        } else {
            self.data.insert(path.to_string(), content.to_string());
            self.write_file(path, content);
        }
    }

    #[cfg(target_family = "unix")]
    pub fn replace(&mut self, path: &str, old: &str, new: &str) {
        let expect_msg = format!("Error reading file in map: {path}");
        let mut current_data = self.data.get(path).expect(&expect_msg).clone();
        current_data = current_data.replace(old, new);
        self.data.insert(path.to_string(), current_data.to_string());
        self.write_file(path, &current_data);
    }

    pub fn appendln(&mut self, path: &str, content: &str) {
        self.append(path, &format!("\n{}\n", content));
    }

    #[cfg(target_family = "unix")]
    pub fn get(&self, path: &str) -> String {
        self.data.get(path).unwrap().clone()
    }

    #[cfg(target_family = "unix")]
    pub fn set(&mut self, path: &str, content: &str) {
        self.data.insert(path.to_string(), content.to_string());
    }

    #[cfg(target_family = "unix")]
    pub fn assert_it_exists(path: &str) {
        if !std::path::Path::new(path).exists() {
            println!("Assertion for file existence failed: {path}");
            std::process::exit(1);
        }
    }
}

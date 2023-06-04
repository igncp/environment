use self::{config::Config, files::Files, system::System};

pub mod config;
pub mod files;
pub mod system;

pub struct Context {
    pub system: System,
    pub files: Files,
    pub config: Config,
}

impl Context {
    pub fn write_file(&mut self, path: &str, clear: bool) {
        let content = self.files.data.get(path).unwrap();

        self.system.write_file(path, content);

        if clear {
            self.files.data.remove(path);
        }
    }

    pub fn write_files(&mut self) {
        for file in &self.files.data.keys().cloned().collect::<Vec<_>>() {
            self.write_file(file, false);
        }
    }
}

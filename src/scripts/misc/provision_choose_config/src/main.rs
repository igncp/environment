use clap::Command;
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use std::io::Write;
use std::{
    collections::{HashMap, HashSet},
    error::Error,
    fs::File,
    io,
    time::{Duration, Instant},
};
use tui::{
    backend::{Backend, CrosstermBackend},
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::Span,
    widgets::{Block, Borders, List, ListItem, ListState},
    Frame, Terminal,
};

struct StatefulList<T> {
    state: ListState,
    items: Vec<T>,
}

impl<T> StatefulList<T> {
    fn with_items(items: Vec<T>) -> StatefulList<T> {
        StatefulList {
            state: ListState::default(),
            items,
        }
    }

    fn next(&mut self) {
        let i = match self.state.selected() {
            Some(i) => {
                if i >= self.items.len() - 1 {
                    0
                } else {
                    i + 1
                }
            }
            None => 0,
        };
        self.state.select(Some(i));
    }

    fn previous(&mut self) {
        let i = match self.state.selected() {
            Some(i) => {
                if i == 0 {
                    self.items.len() - 1
                } else {
                    i - 1
                }
            }
            None => 0,
        };
        self.state.select(Some(i));
    }

    fn unselect(&mut self) {
        self.state.select(None);
    }
}

struct App {
    enabled: HashSet<String>,
    config_content: HashMap<String, String>,
    items: StatefulList<String>,
}

impl App {
    fn new(list: Vec<String>) -> App {
        App {
            enabled: HashSet::new(),
            items: StatefulList::with_items(list),
            config_content: HashMap::new(),
        }
    }

    fn toggle_selected(&mut self) {
        let selected = self.items.state.selected();

        if let Some(i) = selected {
            let item = self.items.items.get(i).expect("No item found");
            let home_dir = std::env::var("HOME").expect("No home dir found");
            let file_path = format!("{home_dir}/development/environment/project/.config/{item}");

            if self.enabled.contains(item) {
                self.enabled.remove(item);
                std::fs::remove_file(file_path).unwrap_or_default();
                self.config_content.remove(&item.clone());
            } else {
                let default_values = get_default_values();
                let empty_string = "".to_string();
                let default_value = default_values.get(item).unwrap_or(&empty_string);
                self.enabled.insert(item.clone());

                std::fs::write(file_path, default_value).expect("Unable to write file");

                if default_value.is_empty() {
                    self.config_content.remove(&item.clone());
                } else {
                    self.config_content
                        .insert(item.clone(), default_value.clone());
                };
            }
        }
    }
}

fn get_all_possible_config() -> Vec<String> {
    let possible_config_rust = std::process::Command::new("bash")
        .arg("-c")
        .arg(r#"grep --no-file -rEo '".config/([_a-zA-Z0-9-])*"' ~/development/environment | sort | uniq"#)
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace(".config/", ""))
        .collect::<Vec<String>>();

    let possible_config_bash = std::process::Command::new("bash")
        .arg("-c")
        .arg(
            r#"grep --no-file -rEo 'PROVISION_CONFIG[^ ]* ' ~/development/environment/src | sort | uniq"#,
        )
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace("PROVISION_CONFIG", ""))
        .collect::<Vec<String>>();

    let possible_config_lua = std::process::Command::new("bash")
        .arg("-c")
        .arg(
            r#"grep --no-file -rEo "(get_config_file_path|has_config)\([^a-z][a-z0-9-]*[^a-z]\)" ~/development/environment/src | sort | uniq"#,
        )
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace("get_config_file_path", ""))
        .map(|x| x.replace("has_config", ""))
        .collect::<Vec<String>>();

    let possible_config_nix = std::process::Command::new("bash")
        .arg("-c")
        .arg(
            r#"grep --no-file -rEo 'base_config \+ "[/a-z0-9-]*"' ~/development/environment/nix | sort | uniq"#,
        )
        .output()
        .expect("Failed to execute command")
        .stdout
        .iter()
        .map(|x| *x as char)
        .collect::<String>()
        .split('\n')
        .map(|x| x.to_string())
        .map(|x| x.replace("base_config +", ""))
        .collect::<Vec<String>>();

    let mut all_possible_config = possible_config_rust
        .iter()
        .chain(possible_config_bash.iter())
        .chain(possible_config_lua.iter())
        .chain(possible_config_nix.iter())
        .map(|x| x.replace(&['(', ')', '"', '\'', '/'][..], ""))
        .map(|x| x.trim().to_string())
        .filter(|x| !x.is_empty())
        .collect::<Vec<String>>();

    all_possible_config.sort();
    all_possible_config.dedup();

    all_possible_config
}

fn get_default_values() -> HashMap<String, String> {
    let mut hash_map = HashMap::new();

    hash_map.insert("vpn_check".to_string(), "yes".to_string());
    hash_map.insert("ssh-notice-color".to_string(), "cyan".to_string());
    hash_map.insert("theme".to_string(), "dark".to_string());

    hash_map
}

// This has been extended from: https://github.com/fdehau/tui-rs/blob/master/Cargo.toml
fn main() -> Result<(), Box<dyn Error>> {
    let matches = Command::new("provision_choose_config")
        .version("1.0.0")
        .about("Handle provision configuration")
        .subcommand(Command::new("fzf").about("Instead of the ncurses gui, it pipes to fzf and sh"))
        .get_matches();

    let home_dir = std::env::var("HOME").expect("No home dir found");

    let config_dir = home_dir + "/development/environment/project/.config";

    let existing_config = std::fs::read_dir(config_dir.clone())
        .expect("Unable to read config dir")
        .map(|x| x.unwrap().file_name().to_str().unwrap().to_string())
        .collect::<std::collections::HashSet<String>>();

    let all_possible_config = get_all_possible_config();

    let existing_files_content: HashMap<String, String> = existing_config
        .iter()
        .map(|x| {
            let file_dir = format!("{config_dir}/{x}");
            let content = std::fs::read_to_string(file_dir).unwrap_or_default();
            let content = content.replace('\n', "");

            (x.to_string(), content)
        })
        .collect();

    let tick_rate = Duration::from_millis(250);
    let mut app = App::new(all_possible_config);

    app.items.items.iter().for_each(|x| {
        if existing_config.contains(x) {
            app.enabled.insert(x.to_string());
            app.config_content
                .insert(x.to_string(), existing_files_content[x].clone());
        }
    });

    if let Some(_) = matches.subcommand_matches("fzf") {
        let mut lines: Vec<String> = vec![];

        for item in app.items.items.iter() {
            let is_enabled = app.enabled.contains(item);

            if is_enabled {
                lines.push(format!(
                    "rm ~/development/environment/project/.config/{item}"
                ));
            } else {
                lines.push(format!(
                    "touch ~/development/environment/project/.config/{item}"
                ));
            }
        }

        let file_path = "/tmp/provision_choose_config";
        let mut file = File::create(file_path).expect("Unable to create file");
        file.write_all(lines.join("\n").as_bytes())
            .expect("Unable to write data");

        std::process::Command::new("bash")
            .arg("-c")
            .arg(format!("cat {file_path} | fzf | sh"))
            .status()
            .expect("Failed to execute command");

        return Ok(());
    }

    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let res = run_app(&mut terminal, app, tick_rate);

    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    if let Err(err) = res {
        println!("Error: {:?}", err)
    }

    Ok(())
}

fn run_app<B: Backend>(
    terminal: &mut Terminal<B>,
    mut app: App,
    tick_rate: Duration,
) -> io::Result<()> {
    let mut last_tick = Instant::now();

    loop {
        terminal.draw(|f| ui(f, &mut app))?;

        let timeout = tick_rate
            .checked_sub(last_tick.elapsed())
            .unwrap_or_else(|| Duration::from_secs(0));

        if crossterm::event::poll(timeout)? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Char('q') => return Ok(()),
                    KeyCode::Left => app.items.unselect(),
                    KeyCode::Down => app.items.next(),
                    KeyCode::PageDown => {
                        for _ in 0..10 {
                            app.items.next();
                        }
                    }
                    KeyCode::Up => app.items.previous(),
                    KeyCode::PageUp => {
                        for _ in 0..10 {
                            app.items.previous();
                        }
                    }
                    KeyCode::Enter | KeyCode::Char(' ') => app.toggle_selected(),
                    _ => {}
                }
            }
        }

        if last_tick.elapsed() >= tick_rate {
            last_tick = Instant::now();
        }
    }
}

fn ui<B: Backend>(f: &mut Frame<B>, app: &mut App) {
    let chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(100)].as_ref())
        .split(f.size());

    let default_values = get_default_values();

    let items: Vec<ListItem> = app
        .items
        .items
        .iter()
        .map(|line_text| {
            let empty_content = "".to_string();
            let content = app.config_content.get(line_text).unwrap_or(&empty_content);

            let mut full_line_text = line_text.clone();
            if app.enabled.contains(line_text) && content != &empty_content {
                if content != &empty_content {
                    full_line_text = format!("{line_text} [{content}]");
                }
            } else if let Some(default_value) = default_values.get(line_text) {
                full_line_text = format!("{line_text} ({default_value})");
            }

            let line = Span::raw(full_line_text);

            let fg = if app.enabled.contains(line_text) {
                Color::Green
            } else {
                Color::White
            };

            ListItem::new(line).style(Style::default().fg(fg).bg(Color::Black))
        })
        .collect();

    let items = List::new(items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title("Possible configuration options:"),
        )
        .highlight_style(Style::default().add_modifier(Modifier::BOLD))
        .highlight_symbol(">> ");

    f.render_stateful_widget(items, chunks[0], &mut app.items.state);
}

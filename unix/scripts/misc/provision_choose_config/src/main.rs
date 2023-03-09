use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use std::{
    collections::{HashMap, HashSet},
    error::Error,
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
            let item = self.items.items.get(i).unwrap();
            let home_dir = std::env::var("HOME").unwrap();
            let file_path = format!("{home_dir}/project/.config/{item}");
            if self.enabled.contains(item) {
                self.enabled.remove(item);
                std::fs::remove_file(file_path).unwrap_or_default();
            } else {
                self.enabled.insert(item.clone());
                std::fs::write(file_path, "").unwrap();
            }
        }
    }
}

// This has been extended from: https://github.com/fdehau/tui-rs/blob/master/Cargo.toml
fn main() -> Result<(), Box<dyn Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let home_dir = std::env::var("HOME").unwrap();
    let provision_file_content =
        std::fs::read_to_string(home_dir.clone() + "/project/provision/provision.sh").unwrap();
    let config_regex = regex::Regex::new(r"project/.config/([a-zA-Z0-9-]*)").unwrap();

    let config_dir = home_dir + "/project/.config";

    let existing_config = std::fs::read_dir(config_dir.clone())
        .unwrap()
        .map(|x| x.unwrap().file_name().to_str().unwrap().to_string())
        .collect::<std::collections::HashSet<String>>();

    let mut all_possible_config_set = config_regex
        .captures_iter(&provision_file_content)
        .map(|x| x[1].to_string())
        .collect::<std::collections::HashSet<String>>();

    existing_config.iter().for_each(|x| {
        all_possible_config_set.insert(x.clone());
    });

    let mut all_possible_config: Vec<String> =
        all_possible_config_set.into_iter().collect::<Vec<String>>();

    all_possible_config.sort();

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
                    KeyCode::Up => app.items.previous(),
                    KeyCode::Enter => app.toggle_selected(),
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

    let items: Vec<ListItem> = app
        .items
        .items
        .iter()
        .map(|line_text| {
            let default_content = "".to_string();
            let content = app
                .config_content
                .get(line_text)
                .unwrap_or(&default_content);

            let mut full_line_text = line_text.clone();
            if content != &default_content {
                full_line_text = format!("{line_text} [{content}]");
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

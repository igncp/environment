use crate::base::IConfig;
use crate::ui::{prepare_ui, teardown_ui, StatefulList, UI};
use crossterm::event::{self, Event, KeyCode};
use std::{
    collections::{HashMap, HashSet},
    error::Error,
    io,
    time::{Duration, Instant},
};
use tui::{
    backend::Backend,
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    text::Span,
    widgets::{Block, Borders, List, ListItem},
    Frame,
};

pub struct App<'a> {
    pub all_items: Vec<String>,
    pub config_content: HashMap<String, String>,
    pub config_enabled: HashSet<String>,
    pub filter_text: String,
    pub items_state: StatefulList<String>,
    pub config_handler: &'a dyn IConfig,
}

impl<'a> App<'a> {
    pub fn new(config_handler: &impl IConfig) -> App {
        let all_possible_config = config_handler.get_all_possible();
        let mut app = App {
            all_items: all_possible_config.clone(),
            config_content: HashMap::new(),
            config_enabled: HashSet::new(),
            filter_text: String::new(),
            items_state: StatefulList::with_items(all_possible_config),
            config_handler,
        };

        let existing_config = config_handler.get_existing();
        let existing_files_content = config_handler.get_content(&existing_config);

        app.items_state.items.iter().for_each(|x| {
            if existing_config.contains(x) {
                app.config_enabled.insert(x.to_string());
                app.config_content
                    .insert(x.to_string(), existing_files_content[x].clone());
            }
        });

        app
    }

    pub fn run(app: App) -> Result<(), Box<dyn Error>> {
        let mut ui = prepare_ui()?;

        let res = run_app(&mut ui, app);

        teardown_ui(&mut ui)?;

        if let Err(err) = res {
            println!("Error: {:?}", err)
        }

        Ok(())
    }

    fn toggle_selected(&mut self, force: Option<bool>) {
        let selected = self.items_state.state.selected();

        if let Some(i) = selected {
            let item = self.items_state.items.get(i).expect("No item found");
            let file_path = self.config_handler.get_config_file_path(item);

            if self.config_enabled.contains(item) {
                if let Some(force) = force {
                    if force {
                        return;
                    }
                }
                self.config_enabled.remove(item);
                std::fs::remove_file(file_path).unwrap_or_default();
                self.config_content.remove(&item.clone());
            } else {
                if let Some(force) = force {
                    if !force {
                        return;
                    }
                }
                let default_values = self.config_handler.get_default_values();
                let empty_string = "".to_string();
                let default_value = default_values.get(item).unwrap_or(&empty_string);
                self.config_enabled.insert(item.clone());

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

    pub fn sync_list(&mut self) {
        self.items_state = StatefulList::with_items(
            self.all_items
                .iter()
                .filter(|x| x.to_lowercase().contains(&self.filter_text.to_lowercase()))
                .cloned()
                .collect(),
        );

        self.items_state.next();
    }
}

fn run_app(ui: &mut UI, mut app: App) -> io::Result<()> {
    let mut last_tick = Instant::now();

    loop {
        ui.terminal.draw(|f| print_frame(f, &mut app))?;

        let timeout = ui
            .tick_rate
            .checked_sub(last_tick.elapsed())
            .unwrap_or_else(|| Duration::from_secs(0));

        if crossterm::event::poll(timeout)? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Esc => return Ok(()),
                    KeyCode::Down => app.items_state.next(),
                    KeyCode::PageDown => {
                        for _ in 0..10 {
                            app.items_state.next();
                        }
                    }
                    KeyCode::Up => app.items_state.previous(),
                    KeyCode::PageUp => {
                        for _ in 0..10 {
                            app.items_state.previous();
                        }
                    }
                    KeyCode::Right => app.toggle_selected(Some(true)),
                    KeyCode::Left => app.toggle_selected(Some(false)),
                    KeyCode::Enter | KeyCode::Char(' ') => app.toggle_selected(None),
                    KeyCode::Backspace => {
                        app.filter_text.pop();
                        app.sync_list();
                    }
                    KeyCode::Char(c) => {
                        app.filter_text.push(c);
                        app.sync_list();
                    }
                    _ => {}
                }
            }
        }

        if last_tick.elapsed() >= ui.tick_rate {
            last_tick = Instant::now();
        }
    }
}

fn print_frame<B: Backend>(f: &mut Frame<B>, app: &mut App) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Min(0), Constraint::Length(2)].as_ref())
        .split(f.size());

    let default_values = app.config_handler.get_default_values();

    let items: Vec<ListItem> = app
        .items_state
        .items
        .iter()
        .filter_map(|line_text| {
            let empty_content = "".to_string();
            let content = app.config_content.get(line_text).unwrap_or(&empty_content);

            let mut full_line_text = line_text.clone();
            if app.config_enabled.contains(line_text) && content != &empty_content {
                if content != &empty_content {
                    full_line_text = format!("{line_text} [{content}]");
                }
            } else if let Some(default_value) = default_values.get(line_text) {
                full_line_text = format!("{line_text} ({default_value})");
            }

            if !app.filter_text.is_empty()
                && !full_line_text
                    .to_lowercase()
                    .contains(&app.filter_text.to_lowercase())
            {
                return None;
            }

            let line = Span::raw(full_line_text);

            let fg = if app.config_enabled.contains(line_text) {
                Color::Green
            } else {
                Color::White
            };

            Some(ListItem::new(line).style(Style::default().fg(fg).bg(Color::Black)))
        })
        .collect();

    let list = List::new(items)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title("Possible configuration options:"),
        )
        .highlight_style(Style::default().add_modifier(Modifier::BOLD))
        .highlight_symbol(">> ");

    let filter = Span::raw(app.filter_text.clone());
    let filter = Block::default().borders(Borders::ALL).title(filter);

    f.render_stateful_widget(list, chunks[0], &mut app.items_state.state);
    f.render_widget(filter, chunks[1]);

    if app.items_state.state.selected().is_none() {
        app.items_state.next();
    }
}

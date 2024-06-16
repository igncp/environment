use crate::base::IConfig;
use crate::ui::{DetailPage, ListPage, StatefulList, UI};
use crossterm::event::{self, Event, KeyCode};
use std::{error::Error, io};
use tui::backend::Backend;
use tui::Frame;

#[derive(Clone)]
enum Screen {
    List,
    Detail(String),
}

pub struct App<'a> {
    config_handler: &'a mut dyn IConfig,
    current_screen: Screen,
    filter_text: String,
    items_state: StatefulList<String>,
}

impl<'a> App<'a> {
    pub fn new(config_handler: &mut impl IConfig) -> App {
        let all_possible_config = config_handler.get_all_possible().clone();

        App {
            config_handler,
            current_screen: Screen::List,
            filter_text: String::new(),
            items_state: StatefulList::with_items(all_possible_config),
        }
    }

    pub fn run(&mut self) -> Result<(), Box<dyn Error>> {
        let mut ui = UI::prepare_ui()?;

        let res = self.run_event_loop(&mut ui);

        ui.teardown_ui()?;

        if let Err(err) = res {
            println!("Error: {:?}", err)
        }

        Ok(())
    }

    fn toggle_selected(&mut self, force: Option<bool>) {
        let selected = self.items_state.state.selected();

        if selected.is_none() {
            return;
        }

        let selected = selected.unwrap();
        let selected = self.items_state.items.get(selected).unwrap();

        self.config_handler.toggle_item(selected, force);
    }

    fn print_list_page<B: Backend>(&mut self, frame: &mut Frame<B>) {
        let default_values = self.config_handler.get_default_values();

        let on_line_filter = |line_text: &str| {
            let empty_content = "".to_string();
            let content = self
                .config_handler
                .get_config_content(line_text)
                .unwrap_or(&empty_content);

            let is_enabled = self.config_handler.is_config_enabled(line_text);

            let mut full_line_text = line_text.to_string();
            if is_enabled && content != &empty_content {
                if content != &empty_content {
                    full_line_text = format!("{line_text} [{content}]");
                }
            } else if let Some(default_value) = default_values.get(line_text) {
                full_line_text = format!("{line_text} ({default_value})");
            }

            if !self.filter_text.is_empty()
                && !full_line_text
                    .to_lowercase()
                    .contains(&self.filter_text.to_lowercase())
            {
                return None;
            }

            Some((full_line_text, is_enabled))
        };

        let mut list_page = ListPage {
            bottom_text: &self.filter_text,
            bottom_title: "Filter:",
            frame,
            items_list: &mut self.items_state,
            list_title: "Possible configuration options:",
            on_line_filter: &on_line_filter,
        };

        list_page.print();

        if self.items_state.state.selected().is_none() {
            self.items_state.next();
        }
    }

    pub fn sync_list(&mut self) {
        self.items_state = StatefulList::with_items(
            self.config_handler
                .get_all_possible()
                .iter()
                .filter(|x| x.to_lowercase().contains(&self.filter_text.to_lowercase()))
                .cloned()
                .collect(),
        );

        self.items_state.next();
    }

    fn print_detail_page<B: Backend>(&self, frame: &mut Frame<B>, item: &String) {
        let empty_content = "".to_string();
        let content = self
            .config_handler
            .get_config_content(&item)
            .unwrap_or(&empty_content);

        let is_enabled = self.config_handler.is_config_enabled(&item);
        let mut content = format!(
            "Enabled: {}",
            if is_enabled {
                format!(
                    "Yes{}",
                    if content != &empty_content {
                        format!(" ({})", content.clone())
                    } else {
                        empty_content.clone()
                    }
                )
            } else {
                "No".to_string()
            }
        );

        content.push_str("\n\n");

        content.push_str(
            self.config_handler
                .get_config_metadata(&item)
                .unwrap_or(empty_content)
                .as_str(),
        );

        let mut detail_page = DetailPage {
            frame,
            title: &format!("{}", item),
            content: &content,
        };

        detail_page.print();
    }

    fn run_event_loop(&mut self, ui: &mut UI) -> io::Result<()> {
        loop {
            ui.terminal
                .draw(|frame| match self.current_screen.clone() {
                    Screen::List => self.print_list_page(frame),
                    Screen::Detail(item) => self.print_detail_page(frame, &item),
                })?;

            let timeout = ui.get_loop_timeout();

            if crossterm::event::poll(timeout)? {
                if let Event::Key(key) = event::read()? {
                    match key.code {
                        KeyCode::Esc => return Ok(()),
                        KeyCode::Down => self.items_state.next(),
                        KeyCode::PageDown => {
                            for _ in 0..10 {
                                self.items_state.next();
                            }
                        }
                        KeyCode::Up => self.items_state.previous(),
                        KeyCode::PageUp => {
                            for _ in 0..10 {
                                self.items_state.previous();
                            }
                        }
                        KeyCode::Right => self.toggle_selected(Some(true)),
                        KeyCode::Left => self.toggle_selected(Some(false)),
                        KeyCode::Char(' ') => self.toggle_selected(None),
                        KeyCode::Enter => {
                            if let Screen::List = self.current_screen {
                                let selected = self.items_state.state.selected();

                                if selected.is_none() {
                                    continue;
                                }

                                let selected = selected.unwrap();
                                let selected = self.items_state.items.get(selected).unwrap();

                                self.current_screen = Screen::Detail(selected.clone());
                            }
                        }
                        KeyCode::Backspace => {
                            if let Screen::Detail(_) = self.current_screen {
                                self.current_screen = Screen::List;
                            } else if !self.filter_text.is_empty() {
                                self.filter_text.pop();
                                self.sync_list();
                            }
                        }
                        KeyCode::Char(c) => {
                            if key.modifiers.contains(event::KeyModifiers::CONTROL) {
                                match c {
                                    'c' => return Ok(()),
                                    'w' => {
                                        if !self.filter_text.is_empty() {
                                            self.filter_text.clear();
                                            self.sync_list();
                                        }
                                    }
                                    _ => {}
                                }
                            } else {
                                self.filter_text.push(c);
                                self.sync_list();
                            }
                        }
                        _ => {}
                    }
                }
            }

            ui.refresh_loop();
        }
    }
}

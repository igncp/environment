use crossterm::event::{DisableMouseCapture, EnableMouseCapture};
use crossterm::execute;
use crossterm::terminal::{
    disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen,
};
use std::error::Error;
use std::io::Stdout;
use std::time::Instant;
use std::{io, time::Duration};
use tui::backend::{Backend, CrosstermBackend};
use tui::layout::Alignment;
use tui::widgets::{Paragraph, Wrap};
use tui::Frame;
use tui::{
    layout::{Constraint, Direction, Layout},
    style::{Color, Modifier, Style},
    widgets::{Block, Borders, List, ListItem, ListState},
    Terminal,
};

pub struct StatefulList<T> {
    pub state: ListState,
    pub items: Vec<T>,
}

impl<T> StatefulList<T> {
    pub fn with_items(items: Vec<T>) -> StatefulList<T> {
        StatefulList {
            state: ListState::default(),
            items,
        }
    }

    pub fn next(&mut self) {
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

    pub fn previous(&mut self) {
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
}

pub struct UI {
    pub terminal: Terminal<CrosstermBackend<Stdout>>,
    tick_rate: Duration,
    last_tick: Instant,
}

impl UI {
    pub fn prepare_ui() -> Result<UI, Box<dyn Error>> {
        enable_raw_mode()?;
        let mut stdout = io::stdout();
        execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
        let backend = CrosstermBackend::new(stdout);
        let terminal = Terminal::new(backend)?;

        let tick_rate = Duration::from_millis(250);
        let last_tick = Instant::now();

        Ok(UI {
            last_tick,
            terminal,
            tick_rate,
        })
    }

    pub fn teardown_ui(&mut self) -> Result<(), Box<dyn Error>> {
        disable_raw_mode()?;
        execute!(
            self.terminal.backend_mut(),
            LeaveAlternateScreen,
            DisableMouseCapture
        )?;
        self.terminal.show_cursor()?;

        Ok(())
    }

    pub fn get_loop_timeout(&self) -> Duration {
        self.tick_rate
            .checked_sub(self.last_tick.elapsed())
            .unwrap_or_else(|| Duration::from_secs(0))
    }

    pub fn refresh_loop(&mut self) {
        if self.last_tick.elapsed() >= self.tick_rate {
            self.last_tick = Instant::now();
        }
    }
}

pub struct ListPage<'a, 'b, B: Backend> {
    pub bottom_text: &'a str,
    pub bottom_title: &'a str,
    pub frame: &'a mut Frame<'b, B>,
    pub items_list: &'a mut StatefulList<String>,
    pub list_title: &'a str,
    pub on_line_filter: &'a dyn Fn(&str) -> Option<(String, bool)>,
}

impl<'a, 'b, B: Backend> ListPage<'a, 'b, B> {
    pub fn print(&mut self) {
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints(
                [
                    Constraint::Min(0),
                    Constraint::Length(if self.bottom_text.is_empty() { 0 } else { 3 }),
                ]
                .as_ref(),
            )
            .split(self.frame.size());

        let items: Vec<ListItem> = self
            .items_list
            .items
            .iter()
            .filter_map(|line_text| {
                let result = (self.on_line_filter)(line_text);

                result.as_ref()?;

                let (line, enabled) = result.unwrap();

                let fg = if enabled { Color::Green } else { Color::White };

                Some(ListItem::new(line).style(Style::default().fg(fg)))
            })
            .collect();

        let list = List::new(items)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .title(self.list_title),
            )
            .highlight_style(Style::default().add_modifier(Modifier::BOLD))
            .highlight_symbol(">> ");

        let filter = Paragraph::new(self.bottom_text).block(
            Block::default()
                .title(self.bottom_title)
                .borders(Borders::ALL),
        );

        self.frame
            .render_stateful_widget(list, chunks[0], &mut self.items_list.state);
        if !self.bottom_text.is_empty() {
            self.frame.render_widget(filter, chunks[1]);
        }
    }
}

pub struct DetailPage<'a, 'b, B: Backend> {
    pub content: &'a str,
    pub frame: &'a mut Frame<'b, B>,
    pub title: &'a str,
}

impl<'a, 'b, B: Backend> DetailPage<'a, 'b, B> {
    pub fn print(&mut self) {
        let chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([Constraint::Percentage(100)].as_ref())
            .split(self.frame.size());

        let paragraph = Paragraph::new(self.content)
            .block(
                Block::default()
                    .borders(Borders::ALL)
                    .title(self.title)
                    .style(Style::default().fg(Color::White)),
            )
            .alignment(Alignment::Left)
            .wrap(Wrap { trim: true });

        self.frame.render_widget(paragraph, chunks[0]);
    }
}

use crossterm::event::{DisableMouseCapture, EnableMouseCapture};
use crossterm::execute;
use crossterm::terminal::{
    disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen,
};
use std::error::Error;
use std::io::Stdout;
use std::{io, time::Duration};
use tui::backend::CrosstermBackend;
use tui::{widgets::ListState, Terminal};

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
    pub tick_rate: Duration,
}

pub fn prepare_ui() -> Result<UI, Box<dyn Error>> {
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let terminal = Terminal::new(backend)?;

    let tick_rate = Duration::from_millis(250);

    Ok(UI {
        terminal,
        tick_rate,
    })
}

pub fn teardown_ui(ui: &mut UI) -> Result<(), Box<dyn Error>> {
    disable_raw_mode()?;
    execute!(
        ui.terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    ui.terminal.show_cursor()?;

    Ok(())
}

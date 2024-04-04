use ncurses::{
    addstr, clear, curs_set, endwin, getch, getmaxyx, initscr, keypad, mv, noecho, raw, refresh,
    stdscr, timeout, CURSOR_VISIBILITY,
};

pub struct UI {
    pub max_x: i32,
    pub max_y: i32,
}

impl UI {
    pub fn new() -> UI {
        UI { max_x: 0, max_y: 0 }
    }

    pub fn sync_dymensions(&mut self) {
        let mut max_x = 0;
        let mut max_y = 0;
        getmaxyx(stdscr(), &mut max_y, &mut max_x);
        self.max_x = max_x;
        self.max_y = max_y;
        clear();
    }

    pub fn paint(&self) {
        refresh();
    }

    fn add_long_str(&self, s: &str) {
        let parsed_str = if s.len() > (self.max_x - 3) as usize {
            format!("{}...", &s[..(self.max_x - 3) as usize])
        } else {
            s.to_string()
        };

        addstr(&parsed_str);
    }

    pub fn add_prompt(&self, legend: &str, bottom: &str) -> i32 {
        mv(self.max_y - 2, 0);
        addstr(legend);
        mv(self.max_y - 1, 0);
        self.add_long_str(bottom);
        refresh();

        timeout(1);
        let ch = getch();

        return ch;
    }

    pub fn init(&self) {
        initscr();
        keypad(stdscr(), true);
        noecho();
        curs_set(CURSOR_VISIBILITY::CURSOR_INVISIBLE);
        raw();
        clear();
    }

    pub fn get_centered_str(&self, s: &str) -> String {
        let padding = (self.max_x - s.len() as i32) / 2;
        let padding_str = " ".repeat(padding as usize);

        return format!("{}{}", padding_str, s);
    }

    pub fn close(&mut self) {
        endwin();
    }
}

pub use self::install::install_node_modules;
pub use self::vue::setup_js_vue;
use self::{base::run_js_base, syntax::run_js_syntax, ts::run_ts};
use crate::base::Context;

mod base;
mod install;
mod syntax;
mod ts;
mod vue;

pub fn run_js(context: &mut Context) {
    run_js_base(context);
    run_js_syntax(context);
    run_ts(context);
}

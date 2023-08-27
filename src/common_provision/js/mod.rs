pub use self::install::install_node_modules;
use self::{base::run_js_base, syntax::run_js_syntax, ts::run_ts};
pub use self::{react::setup_js_react, vue::setup_js_vue};
use crate::base::Context;

mod base;
mod install;
mod react;
mod syntax;
mod ts;
mod vue;

pub fn run_js(context: &mut Context) {
    run_js_base(context);
    run_js_syntax(context);
    run_ts(context);
}

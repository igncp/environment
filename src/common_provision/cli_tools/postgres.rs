use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_postgres(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/postgres")
        && !context.system.get_has_binary("pgcli")
    {
        // https://www.pgcli.com/docs
        System::run_bash_command(
            r###"
pip install setuptools
pip install pgcli
"###,
        );
    }
}

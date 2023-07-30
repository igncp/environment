use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_postgres(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/postgres") {
        return;
    }

    if !context.system.get_has_binary("pgcli") {
        // https://www.pgcli.com/docs
        System::run_bash_command(
            r###"
pip install setuptools
pip install pgcli
"###,
        );
    }

    // Using with nix: https://mgdm.net/weblog/postgresql-in-a-nix-shell/

    context.home_append(
        ".shell_alias",
        r###"
# For when using nix. To run `createdb` need to pass the host, which will be `localhost`
alias PostgresInitLocal='pg_ctl -D .tmp/mydb -l logfile -o "--unix_socket_directories=$PWD" start'
alias PostgresStopLocal='pg_ctl -D .tmp/mydb -l logfile -o "--unix_socket_directories=$PWD" stop'
"###,
    );
}

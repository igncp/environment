use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_postgres(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/postgres") {
        return;
    }

    if !context.system.get_has_binary("pgcli") && !context.system.is_nix_provision {
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
        ".shell_aliases",
        r###"
# Example to connect when started: `pgcli -h localhost -d postgres`
alias PostgresInitLocal='initdb -D .tmp/mydb'
alias PostgresStartLocal='pg_ctl -D .tmp/mydb -l logfile -o "--unix_socket_directories=$PWD" start'
alias PostgresStopLocal='pg_ctl -D .tmp/mydb -l logfile -o "--unix_socket_directories=$PWD" stop'
"###,
    );
}

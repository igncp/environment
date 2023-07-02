use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_hasura(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/hasura") {
        if !context.system.get_has_binary("hasura") {
            System::run_bash_command(
                r###"
mkdir -p ~/.local/bin
curl -L https://github.com/hasura/graphql-engine/raw/stable/cli/get.sh | INSTALL_PATH=$HOME/.local/bin bash
"###,
            );
        }

        context.files.append(
            &context.system.get_home_path(".shellrc"),
            r###"
export HASURA_GRAPHQL_ENABLE_TELEMETRY=false
"###,
        );
    }
}

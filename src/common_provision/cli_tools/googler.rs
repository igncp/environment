use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_googler(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/cli-googler") {
        if !context.system.get_has_binary("googler") {
            // https://github.com/jarun/googler/releases
            System::run_bash_command(
                r###"
sudo curl -o /usr/local/bin/googler \
      https://raw.githubusercontent.com/jarun/googler/v4.3.2/googler
sudo chmod +x /usr/local/bin/googler
sudo googler -u
sudo curl -o /usr/share/bash-completion/completions/googler \
      https://raw.githubusercontent.com/jarun/googler/master/auto-completion/bash/googler-completion.bash
"###,
            );
        }

        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
# using lowercase for autocomplete
alias googler='googler -C -n 4'
alias SO='googler -C -n 4 -w https://stackoverflow.com/'
"###,
        );
    }
}

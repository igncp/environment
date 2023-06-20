use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_jira(context: &mut Context) {
    // https://github.com/go-jira/jira/releases
    if Config::has_config_file(&context.system, ".config/cli-go-jira")
        && !context.system.is_arm()
        && !context.system.get_has_binary("jira")
    {
        System::run_bash_command(
            r###"
cd ~; rm -rf go_jira; mkdir -p go_jira; cd go_jira
wget https://github.com/go-jira/jira/releases/download/v1.0.27/jira-linux-amd64
sudo mv jira-linux-amd64 /usr/bin/jira
sudo chmod +x /usr/bin/jira
cd ~; rm -rf go_jira
"###,
        );
    }
}

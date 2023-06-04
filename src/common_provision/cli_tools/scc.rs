use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_scc(context: &mut Context) {
    if Config::has_config_file(&context.system, "cli-scc") && !context.system.get_has_binary("scc")
    {
        let mut filter = "Linux.*86_64";
        if context.system.is_arm() {
            if context.system.is_mac() {
                filter = "Darwin.*arm64";
            } else {
                filter = "Linux.*arm64";
            }
        }

        let cmd = format!(
            r###"
cd ~
curl -s https://api.github.com/repos/boyter/scc/releases/latest \
  | grep browser \
  | grep gz \
  | grep "{filter}" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | xargs wget
tar -xf scc*.tar.gz
rm -rf scc*.tar.gz
sudo mv scc /usr/local/bin
"###
        );

        System::run_bash_command(&cmd);
    }
}

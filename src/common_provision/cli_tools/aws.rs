use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;

pub fn setup_aws(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/cli-aws") {
        // https://docs.aws.amazon.com/cli/latest/reference/
        if !context.system.get_has_binary("aws") {
            if context.system.is_arm() {
                println!("Provision for ARM missing");
                return;
            }

            System::run_bash_command(
                r###"
mkdir -p /tmp/misc
cd /tmp/misc
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
"###,
            );
        }
        context.files.appendln(
            &context.system.get_home_path(".bashrc"),
            "complete -C '/usr/local/bin/aws_completer' aws",
        );

        context.files.append(
            &context.system.get_home_path(".zshrc"),
            r###"
if ! type complete > /dev/null 2>&1 ; then
  autoload bashcompinit && bashcompinit
fi
complete -C '/usr/local/bin/aws_completer' aws
"###,
        );
    }
}

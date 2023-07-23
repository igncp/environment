use std::path::Path;

use crate::base::{config::Config, Context};

pub fn setup_copyq(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/copyq") {
        return;
    }

    context.system.install_system_package("copyq", None);

    // https://copyq.readthedocs.io/en/latest/faq.html#how-to-omit-storing-text-copied-from-specific-windows-like-a-password-manager
    // Create two items, one for the password manager and one for Entry
    // Click: "Show Advance", then click "Advanced" tab and put text on "Window" input (instead of "Password")
    if !Path::new(&context.system.get_home_path(".check-files/copyq-passwords")).exists() {
        println!("[~/.check-files/copyq-passwords]: Add and test command to filter out copied passwords and remove this message");
    }

    context.home_append(
        ".shell_aliases",
        r###"
CopyQReadN() {
  for i in {0..$1}; do
    echo "$i"
    copyq read "$i"
    echo ""; echo ""
  done
}
"###,
    );

    // TODO: Check
    //   sed -i '1i(sleep 10s && copyq 2>&1 > /dev/null) &' ~/.xinitrc
}

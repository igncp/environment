use std::path::Path;

use crate::base::config::Config;
use crate::base::system::System;
use crate::base::Context;
use crate::common_provision::js::install_node_modules;

use self::aws::setup_aws;
use self::github::setup_gh;
use self::googler::setup_googler;
use self::hasura::setup_hasura;
use self::jira::setup_jira;
use self::postgres::setup_postgres;
use self::scc::setup_scc;

mod aws;
mod github;
mod googler;
mod hasura;
mod jira;
mod postgres;
mod scc;

pub fn run_cli_tools(context: &mut Context) {
    if Config::has_config_file(&context.system, ".config/cli-openvpn") {
        context.system.install_system_package("openvpn", None);
        std::fs::create_dir_all(context.system.get_home_path(".openvpn")).unwrap();

        context.files.append(
            &context
                .system
                .get_home_path(".openvpn/_start_cli_template.sh"),
            r###"
#!/usr/bin/env bash
sudo openvpn \
  --config $HOME/.openvpn/LOCATION.ovpn \
  --script-security 2 \
  --auth-user-pass $HOME/.openvpn/creds.txt \
  --up /etc/openvpn/update-systemd-resolved \
  --down /etc/openvpn/update-systemd-resolved \
  --dhcp-option 'DOMAIN-ROUTE .' \
  --down-pre
"###,
        );
    }

    // `doctl`
    // Download the latest release from: https://github.com/digitalocean/doctl/releases/
    // The `doctl completion zsh` and the ohmyzsh plugin didn't work during tests
    if context.system.get_has_binary("doctl") {
        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
# Keep the token encrypted and don't keep the user logged in
alias DOLogin='doctl auth init'
alias DOLogout='doctl auth remove --context default'
alias DODroplets='doctl compute droplet list'
"###,
        );
    }

    context.system.install_system_package("age", None); // https://github.com/FiloSottile/age

    if Config::has_config_file(&context.system, ".config/cli-vercel") {
        install_node_modules(context, vec![("vercel", None)]);
    }

    // hhighlighter: `h` command
    if !Path::new(&context.system.get_home_path("hhighlighter/h.sh")).exists() {
        System::run_bash_command(
            r###"
rm -rf ~/hhighlighter
 git clone --depth 1 https://github.com/paoloantinori/hhighlighter.git ~/hhighlighter
"###,
        );
    }
    context.files.appendln(
        &context.system.get_home_path(".shell_sources"),
        "source_if_exists ~/hhighlighter/h.sh",
    );
    context.system.install_system_package("ack", None);

    if !context.system.is_arm() {
        context.system.install_system_package("pandoc", None); // document conversion
    }

    context
        .system
        .install_system_package("graphviz", Some("dot"));

    // Potential installs:
    // - https://github.com/firebase/firebase-tools
    // - https://support.crowdin.com/cli-tool/

    // https://github.com/sharkdp/bat
    context.system.install_system_package("bat", None);
    std::fs::create_dir_all(context.system.get_home_path(".config/bat")).unwrap();
    context.files.append(
        &context.system.get_home_path(".config/bat/config"),
        r###"
# Force colors to see in less, otherwise use normal `cat`
-f
# The default theme doesn't display the numbers with existing colors
--theme=Nord
--style="numbers,changes,header"
"###,
    );
    if !context.system.is_nixos()
        && Path::new("/usr/bin/batcat").exists()
        && !Path::new("/usr/bin/bat").exists()
    {
        System::run_bash_command("sudo ln -s /usr/bin/batcat /usr/bin/bat");
    }

    if context.system.is_mac() || context.system.is_arch() {
        // JSON viewer: https://github.com/antonmedv/fx
        context.system.install_system_package("fx", None);

        // https://github.com/dalance/procs
        context.system.install_system_package("procs", None);
        // System::run_bash_command("procs --gen-completion-out zsh >> ~/.scripts/procs_completion");

        context.files.appendln(
            &context.system.get_home_path(".zshrc"),
            "fpath=(~/.scripts/procs_completion $fpath)",
        );
    }

    setup_aws(context);
    setup_scc(context);
    setup_jira(context);
    setup_googler(context);
    setup_gh(context);
    setup_hasura(context);
    setup_postgres(context);

    // https://github.com/kislyuk/yq
    if !context.system.get_has_binary("yq") {
        System::run_bash_command("pip install yq");
    }

    if !context.system.is_mac() && !context.system.is_nixos() {
        // To hide output: `hurl --no-output /tmp/test.txt`
        context.system.install_cargo_crate("hurl", None); // https://github.com/Orange-OpenSource/hurl
    }

    context.system.install_cargo_crate("sd", None); // https://github.com/chmln/sd
    context.system.install_cargo_crate("hyperfine", None); // https://github.com/sharkdp/hyperfine
    context.system.install_cargo_crate("ast-grep", Some("sg")); // https://github.com/ast-grep/ast-grep
    context
        .system
        .install_cargo_crate("git-delta", Some("delta")); // https://github.com/dandavison/delta

    // https://github.com/ms-jpq/sad
    if context.system.is_arch() {
        context.system.install_system_package("sad", None);
    } else if context.system.is_ubuntu() && !context.system.get_has_binary("sad") {
        println!("Download and install sad from https://github.com/ms-jpq/sad/releases/latest")
    }
}

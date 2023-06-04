use crate::base::Context;

pub fn run_netcat_clipboard(context: &mut Context) {
    if context.config.netcat_clipboard {
        context.files.append(
            &context.system.get_home_path(".scripts/netcat-clipboard.sh"),
            r###"
cat /tmp/netcat-clipboard | nc -q0 localhost 5556
rm -rf /tmp/netcat-clipboard
"###,
        );

        context.files.append(
            &context.system.get_home_path(".shell_aliases"),
            r###"
# Remote forward the port in ~/.ssh/config of the client
alias ClipboardNetcatSender='nc -q0 localhost 5556'
"###,
        );
    }

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias ClipboardNetcatReceiver='while (true); do nc -l 5556 | pbcopy; done'
"###,
    );
}

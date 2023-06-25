use crate::base::{config::Config, Context};

pub fn setup_clipboard_ssh(context: &mut Context) {
    let vim_file_path = context.system.get_home_path(".vimrc");

    // In the host `.ssh/config` file add this to forward the remote port into the local
    // RemoteForward 2030 localhost:2030

    context.files.append(
        &vim_file_path,
        if Config::has_config_file(&context.system, ".config/clipboard-ssh") {
            r###"
" Copy to clipboard
vnoremap <leader>i y:call writefile(getreg('0', 1, 1), "/tmp/clipboard-ssh")<cr>:silent !cat /tmp/clipboard-ssh \| ~/.scripts/cargo_target/release/clipboard_ssh send<cr><cr>
nnoremap <leader>i viwy:call writefile(getreg('0', 1, 1), "/tmp/clipboard-ssh")<cr>:silent !cat /tmp/clipboard-ssh \| ~/.scripts/cargo_target/release/clipboard_ssh send<cr><cr>
nnoremap <leader>I viWy:call writefile(getreg('0', 1, 1), "/tmp/clipboard-ssh")<cr>:silent !cat /tmp/clipboard-ssh \| ~/.scripts/cargo_target/release/clipboard_ssh send<cr><cr>
"###
        } else {
r###"
" Copy to clipboard
vnoremap <leader>i "+y
nnoremap <leader>i viw"+y
nnoremap <leader>I viW"+y
"### },
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias ClipboardSSHSend="~/.scripts/cargo_target/release/clipboard_ssh send"
"###,
    );
}

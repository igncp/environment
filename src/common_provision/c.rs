use crate::base::{config::Config, system::System, Context};

pub fn setup_c(context: &mut Context) {
    if !Config::has_config_file(&context.system, "c") {
        return;
    }

    // astyle: http://astyle.sourceforge.net/astyle.html

    context.system.install_system_package("ctags", None);

    if !context.system.get_has_binary("clib") {
        System::run_bash_command(
            r###"
echo "Installing clib"
sudo rm -rf /tmp/clib
git clone https://github.com/clibs/clib.git /tmp/clib
cd /tmp/clib
sudo make install
"###,
        );
    }

    context.files.append(&context.system.get_home_path(".vimrc"),
r###"
autocmd Filetype c,cc setlocal softtabstop=4 tabstop=4 shiftwidth=4
autocmd filetype c,cc :exe 'vnoremap <leader>kks yOprintf("P: %s\n", P);<c-c>FP;vpgvy$FPvp_'
autocmd filetype c,cc :exe "nnoremap <silent> <leader>kb :!astyle --style=allman --indent-after-parens %<cr>:e<cr>"
autocmd filetype c,cc set iskeyword-=-
"###,
    );

    context.files.appendln(
        &context.system.get_home_path(".shell_aliases"),
        "alias GdbGui='gdbgui -p 9002 --host 0.0.0.0'",
    );

    // This currently has an error on install
    // if !context.system.get_has_binary("gdbgui") {
    //     System::run_bash_command("pip install gdbgui");
    // }

    if !context.system.get_has_binary("gcovr") {
        System::run_bash_command("pip install gcovr");
    }
}

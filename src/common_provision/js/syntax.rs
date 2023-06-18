use crate::{base::Context, common_provision::vim::install_nvim_package};

pub fn run_js_syntax(context: &mut Context) {
    context.files.append(
        "/tmp/clean-vim-js-syntax.sh",
        r###"
sed -i 's|const |async await |' ~/.local/share/nvim/lazy/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|let var |let var const |' ~/.local/share/nvim/lazy/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|export from|export|' ~/.local/share/nvim/lazy/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|import public|import from type public|' ~/.local/share/nvim/lazy/vim-javascript-syntax/syntax/javascript.vim
echo "Changed vim javascript syntax"
"###
    );

    // Not installing vim-javascript as it doesn't work with rainbow
    install_nvim_package(
        context,
        "jelera/vim-javascript-syntax",
        Some("sh /tmp/clean-vim-js-syntax.sh"),
    );
}

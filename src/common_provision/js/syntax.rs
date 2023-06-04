use crate::{base::Context, common_provision::vim::install_vim_package};

pub fn run_js_syntax(context: &mut Context) {
    context.files.append(
        "/tmp/clean-vim-js-syntax.sh",
        r###"
sed -i 's|const |async await |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|let var |let var const |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|export from|export|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|import public|import from type public|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
echo "Changed vim javascript syntax"
"###
    );

    // Not installing vim-javascript as it doesn't work with rainbow
    install_vim_package(
        context,
        "jelera/vim-javascript-syntax",
        Some("sh /tmp/clean-vim-js-syntax.sh"),
    );
}

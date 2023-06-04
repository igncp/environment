use std::fs;
use std::path::Path;

use crate::base::system::System;
use crate::{
    base::Context,
    common_provision::{vim::add_special_vim_map, zsh::install_omzsh_plugin},
};

use super::install::install_node_modules;

pub fn run_js_base(context: &mut Context) {
    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
" quick console.log (maybe used by typescript later on)
  let ConsoleMappingA="vnoremap <leader>kk \"iyOconsole.log('a', a);<C-c>6hidebug: <c-r>=expand('%:t')<cr>: <c-c>lv\"ipf'lllv\"ip"
  let ConsoleMappingB="nnoremap <leader>kk Oconsole.group('%c ', 'background: yellow; color: black', 'A'); console.log(new Error()); console.groupEnd()<c-c>FAa<bs>"
  let ConsoleMappingC="vnoremap <leader>ko yO(global as any).el = <C-c>p"
  autocmd filetype javascript,typescript,typescriptreact,vue :exe ConsoleMappingA
  autocmd filetype javascript,typescript,typescriptreact,vue :exe ConsoleMappingB
  autocmd filetype javascript,typescript,typescriptreact,vue :exe ConsoleMappingC

" run eslint or prettier over file
  autocmd filetype javascript,vue :exe "nnoremap <silent> <leader>kb :!eslint_d --fix %<cr>:e<cr>"
  autocmd filetype javascript,vue :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  autocmd filetype javascript,vue :exe "vnoremap <silent> <leader>kB :'<,'>PrettierFragment<cr>"
  autocmd filetype javascript,vue :exe "nnoremap <silent> <c-a> :update<cr>:!eslint_d --fix %<cr>:e<cr>"
  autocmd filetype javascript,vue :exe "inoremap <silent> <c-a> <c-c>:update<cr>:!eslint_d --fix %<cr>:e<cr>"
  autocmd filetype css,sass,html :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  " --tab-width 4 is for BitBucket lists
  autocmd filetype markdown :exe "nnoremap <silent> <leader>kB :!npx prettier --write --tab-width 4 %<cr>:e<cr>"
  autocmd filetype json :exe "nnoremap <silent> <leader>kB :!npx prettier --write --tab-width 2 %<cr>:e<cr>"

" convert json to jsonc to allow comments
  augroup JsonToJsonc
    autocmd! FileType json set filetype=jsonc
  augroup END

" add return to JS function (e.g. in arrow function)
  vnoremap <leader>er di{}<c-c>i<cr>return <c-c>p

function! g:RunCtrlPWithFilterInNewTab(query)
  let g:ctrlp_default_input=a:query
  execute '-tabnew'
  execute 'CtrlP'
  let g:ctrlp_default_input=''
endfunction

let g:SpecialImports_Cmd_Default_End=' | sed -r "s|^([^.])|./\1|"'
  \ . ' | grep -E "(\.js|\.s?css|\.ts|\.vue)$" | grep -v "__tests__" | sed "s|\.js$||; s|/index$||"'
  \ . ' > /tmp/vim_special_import;'
  \ . ' jq ".dependencies,.devDependencies | keys" package.json | grep -o $"\".*" | sed $"s|\"||g; s|,||"'
  \ . ' >> /tmp/vim_special_import) && cat /tmp/vim_special_import'
let g:SpecialImports_Cmd_Rel_Default='(find ./src -type f | xargs realpath --relative-to="$(dirname <CURRENT_FILE>)"'
  \ . g:SpecialImports_Cmd_Default_End
let g:SpecialImports_Cmd_Full_Default='(DIR="./src";  find "$DIR" -type f | xargs realpath --relative-to="$DIR"'
  \ . g:SpecialImports_Cmd_Default_End . ' | sed "s|^\.|@|"'
let g:SpecialImports_Cmd=g:SpecialImports_Cmd_Full_Default

function! s:SpecialImportsSink(selected)
  execute "norm! o \<c-u>import  from '". a:selected . "'\<c-c>I\<c-right>"
  call feedkeys('i', 'n')
endfunction

function! SpecialImports()
  let l:final_cmd = substitute(g:SpecialImports_Cmd, "<CURRENT_FILE>", expand('%:p'), "")
  let file_content = system(l:final_cmd)
  let source_list = split(file_content, '\n')
  let options_dict = {
    \ 'options': ' --prompt "File (n)> " --ansi --no-hscroll --nth 1,..',
    \ 'source': source_list,
    \ 'sink': function('s:SpecialImportsSink')}

  call fzf#run(options_dict)
endfunction

nnoremap <leader>jss :call SpecialImports()<cr>
nnoremap <leader>jsS :let g:SpecialImports_Cmd='<c-r>=g:SpecialImports_Cmd<cr>'<home><c-right><c-right><right>
nnoremap <leader>jsQ :let g:SpecialImports_Cmd='<c-r>=g:SpecialImports_Cmd_Full_Default<cr>'<home><c-right><c-right><right>
nnoremap <leader>jsW :let g:SpecialImports_Cmd='<c-r>=g:SpecialImports_Cmd_Rel_Default<cr>'<home><c-right><c-right><right>

" t for test
nnoremap <leader>kpt :let g:ctrlp_default_input='__tests__'<cr>:CtrlP<cr>:let g:ctrlp_default_input=''<cr>

  function! ToggleItOnly()
    execute "normal! ?it(\\|it.only(\<cr>\<right>\<right>"
    let current_char = nr2char(strgetchar(getline('.')[col('.') - 1:], 0))
    if current_char == "."
      execute "normal! v4l\<del>"
    else
      execute "normal! i.only\<c-c>"
    endif
    execute "normal! \<c-o>"
  endfunction
  autocmd filetype javascript,typescript,typescriptreact :exe 'nnoremap <leader>zo :call ToggleItOnly()<cr>'

  nnoremap <leader>BT :let g:Fast_grep_opts='--exclude-dir="__tests__" --exclude-dir="__integration__" -i'<left>

" Copy selected string encoded into clipboard
vnoremap <leader>jz y:!node -e "console.log(encodeURIComponent('<c-r>"'))" > /tmp/vim-encode.txt<cr>:let @+ = join(readfile("/tmp/vim-encode.txt"), "\n")<cr><cr>
"###,
    );

    install_omzsh_plugin(context, "lukechilds/zsh-better-npm-completion");

    context.files.append(
        &context.system.get_home_path(".shellrc"),
        r###"
alias ShellChangeToZsh='chsh -s /bin/zsh; exit'
"###,
    );

    if !Path::new(&context.system.get_home_path(".nvm")).exists()
        && !context.system.get_has_binary("node")
    {
        System::run_bash_command(
            r###"
NODE_VERSION=16.20.0
. $HOME/.asdf/asdf.sh
(asdf plugin add nodejs || true)

asdf install nodejs "$NODE_VERSION"
asdf global nodejs "$NODE_VERSION"
"###,
        );
    }

    install_node_modules(context, ["http-server", "yarn", "zx"].to_vec());

    // https://github.com/sgentle/caniuse-cmd
    install_node_modules(context, ["caniuse-cmd"].to_vec());

    install_node_modules(context, ["markdown-toc"].to_vec());

    add_special_vim_map(
        context,
        [
            "cpfat",
            r#":call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr>test\')<cr> "#,
            "ctrlp filename adding test",
        ],
    );

    add_special_vim_map(
        context,
        [
            "cpfrt",
            r#":call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr><bs><bs><bs><bs><bs>\')<cr>"#,
            "ctrlp filename removing test",
        ],
    );

    add_special_vim_map(
        context,
        [
            "ctit",
            r#"? it(<cr>V$%y$%o<cr><c-c>Vpf(2l"#,
            "test copy it test case content",
        ],
    );

    add_special_vim_map(
        context,
        [
            "ctde",
            r#"? describe(<cr>V$%y$%o<cr><c-c>Vpf(2l"#,
            "test copy describe test content",
        ],
    );

    add_special_vim_map(
        context,
        [
            "eeq",
            r#"iXexpectEqual<c-o>:call feedkeys("<c-l>", "t")<cr>"#,
            "test expect toEqual",
        ],
    );

    add_special_vim_map(
        context,
        ["sjsfun", "v/[^,] {<cr><right>%", "select js function"],
    );

    add_special_vim_map(
        context,
        ["djsfun", "v/[^,] {<cr><right>%d", "cut js function"],
    );

    add_special_vim_map(
        context,
        [
            "tjmvs",
            r#"I<c-right><right><c-c>viwy?describe(<cr>olet <c-c>pa;<c-c><c-o><left>v_<del>"#,
            "jest move variable outside of it",
        ],
    );

    add_special_vim_map(
        context,
        [
            "titr",
            r#"_ciwconst<c-c>/from<cr>ciw= require(<del><c-c>$a)<c-c>V:<c-u>%s/\%V\C;//g<cr>"#,
            "transform import to require",
        ],
    );

    add_special_vim_map(
        context,
        ["jimc", "a.mock.calls<c-c>", "jest instert mock calls"],
    );

    add_special_vim_map(
        context,
        [
            "jimi",
            "a.mockImplementation(() => )<left>",
            "jest instert mock implementation",
        ],
    );

    add_special_vim_map(
        context,
        [
            "jirv",
            "a.mockReturnValue()<left>",
            "jest instert mock return value",
        ],
    );

    add_special_vim_map(
        context,
        [
            "ftcrefuntype",
            r#"viwyi<c-right><left>: <c-c>pviwyO<c-c>Otype <c-c>pa = () => <c-c>4hi"#,
            "typescript create function type",
        ],
    );

    add_special_vim_map(
        context,
        [
            "jrct",
            r"gv:<c-u>%s/\%V\C+//ge<cr>:<c-u>%s/\%V\CObject //ge<cr>:<c-u>%s/\%V\CArray //ge<cr>:<c-u>%s/\%V\C\[Fun.*\]/expect.any(Function)/ge<cr>",
            "jest replace copied text from terminal",
        ],
    );

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
Serve() { PORT="$2"; http-server -c-1 -p "${PORT:=9000}" $1; }
"###,
    );

    context.files.append(
        &context.system.get_home_path(".vim-macros"),
        r###"
" Convert jsx prop to object property
_f=i\<del>: \<c-c>\<right>%s,\<c-c>``s\<c-c>``j

" Create test property
_f:v$\<left>\<del>A: \<c-c>_viwyA''\<c-c>\<left>paValue\<c-c>A,\<c-c>_\<down>

" wrap type object in tag
i<\<c-c>\<right>%a>\<c-c>\<left>%\<left>
"###,
    );

    let completion_path = &context.system.get_home_path(".npm-completion");
    if !Path::new(&completion_path).exists() {
        System::run_bash_command(&format!(
            ". $HOME/.asdf/asdf.sh ; npm completion > {completion_path}"
        ))
    }
    let npm_completion = fs::read_to_string(completion_path).unwrap();
    context
        .files
        .append(&context.system.get_home_path(".shellrc"), &npm_completion);

    context
        .files
        .appendln("/tmp/expected-vscode-extensions", "dbaeumer.vscode-eslint");
}

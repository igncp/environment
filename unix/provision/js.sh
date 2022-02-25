# js START

# Dependencies:
# - after: vim-extra.sh

# don't use asdf if NVM is set up as they can create conflict
if [ -d "$HOME"/.nvm ]; then
  # install manually first: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  install_node_modules() {
    NODE_VERSION="$(node --version)"
    for MODULE_NAME in "$@"; do
      if [ ! -d "$HOME/.nvm/versions/node/$NODE_VERSION/lib/node_modules/$MODULE_NAME" ]; then
        echo "doing: npm i -g $MODULE_NAME"
        npm i -g $MODULE_NAME
      fi
    done
  }
  cat >> ~/.shellrc <<"EOF"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
else
  install_node_modules() {
    NODE_VERSION="$(node --version | sed 's|^v||')"
    for MODULE_NAME in "$@"; do
      if [ ! -d "$HOME/.asdf/installs/nodejs/$NODE_VERSION/.npm/lib/node_modules/$MODULE_NAME" ]; then
        echo "doing: npm i -g $MODULE_NAME"
        npm i -g $MODULE_NAME
      fi
    done
  }
fi

if [ ! -d ~/.nvm ] && ! type node > /dev/null 2>&1 ; then
  NODE_VERSION=16.13.2
  (asdf plugin add nodejs || true)

  asdf install nodejs "$NODE_VERSION"
  asdf global nodejs "$NODE_VERSION"
fi

install_node_modules http-server yarn

cat >> ~/.shell_aliases <<"EOF"
Serve() { PORT="$2"; http-server -c-1 -p "${PORT:=9000}" $1; }
EOF

cat > /tmp/clean-vim-js-syntax.sh <<"EOF"
sed -i 's|const |async await |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|let var |let var const |' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|export from|export|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
sed -i 's|import public|import from type public|' ~/.vim/bundle/vim-javascript-syntax/syntax/javascript.vim
echo "Changed vim javascript syntax"
EOF

# coc

## ctrl-w,ctrl-p: move to floating window
## To remove an extension after installed, comment lines and then:
##    :CocUninstall coc-name

install_vim_package neoclide/coc.nvim
install_vim_package josa42/coc-sh
install_vim_package neoclide/coc-snippets

cat >> ~/.vimrc <<"EOF"
function! GetColorInCursor()
  echo synIDattr(synID(line("."), col("."), 1), "name")
endfunction

let g:coc_global_extensions = []
nnoremap <silent> K :call CocAction('doHover')<CR>

inoremap <expr> <c-j> pumvisible() ? "<C-n>" :"j"
inoremap <expr> <c-k> pumvisible() ? "<C-p>" : "k"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)
nmap <leader>do <Plug>(coc-codeaction)
" nmap <leader>rn <Plug>(coc-rename)
nnoremap <silent> <leader>dd :<C-u>CocList diagnostics<cr>

nnoremap <leader>dc :CocEnable<cr>
nnoremap <leader>dC :CocDisable<cr>
nnoremap <leader>ds :CocCommand<cr>
nnoremap <leader>da :CocAction<cr>

call add(g:coc_global_extensions, 'coc-snippets')
call add(g:coc_global_extensions, 'coc-sh')

imap <C-l> <Plug>(coc-snippets-expand-jump)
smap <C-l> <Plug>(coc-snippets-expand-jump)
let g:coc_snippet_next = '<c-d>'

nnoremap <nowait><expr> <C-g> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-g> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
EOF

cat >> ~/.vim/colors.vim <<"EOF"
highlight CocErrorFloat ctermfg=black
highlight CocFloating ctermbg=lightcyan
highlight CocInfoFloat ctermfg=black
highlight CocWarningFloat ctermfg=black
highlight CocHighlightRead ctermfg=black ctermbg=none
highlight CocHighlightWrite ctermfg=black ctermbg=none
highlight CocErrorLine ctermfg=black ctermbg=none
highlight CocWarningLine ctermfg=black ctermbg=none
highlight CocInfoLine ctermfg=black ctermbg=none
highlight CocErrorSign ctermfg=white ctermbg=darkred
highlight CocWarningSign ctermfg=white ctermbg=darkred
EOF

cat > "$HOME"/.vim/coc-settings.json <<"EOF"
{
  "diagnostic.enableHighlightLineNumber": false,
  "coc.preferences.jumpCommand": "tab drop",
  "coc.preferences.enableFloatHighlight": false,
  "coc.preferences.colorSupport": false,
  "snippets.userSnippetsDirectory": "$HOME/.vim-snippets",
  "diagnostic.errorSign": "E",
  "diagnostic.warningSign": "W",
  "diagnostic.infoSign": "I",
  "list.normalMappings": {
    "<C-j>": "command:CocNext",
    "<C-k>": "command:CocPrev"
  }
}
EOF

install_vim_package neoclide/coc-json

cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-json')
EOF

# not installing vim-javascript as it doesn't work with rainbow
install_vim_package jelera/vim-javascript-syntax "sh /tmp/clean-vim-js-syntax.sh"

cat >> ~/.vimrc <<"EOF"
" quick console.log (maybe used by typescript later on)
  let ConsoleMappingA="vnoremap <leader>kk \"iyOconsole.log('a', a);<C-c>6hi<c-r>=expand('%:t')<cr>: <c-c>lv\"ipf'lllv\"ip"
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
  autocmd filetype html :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  " --tab-width 4 is for BitBucket lists
  autocmd filetype markdown :exe "nnoremap <silent> <leader>kB :!npx prettier --write --tab-width 4 %<cr>:e<cr>"
  autocmd filetype json :exe "nnoremap <silent> <leader>kB :!npx prettier --write --tab-width 2 %<cr>:e<cr>"

" convert json to jsonc to allow comments
  augroup JsonToJsonc
    autocmd! FileType json set filetype=jsonc
  augroup END
EOF

install_node_modules markdown-toc
cat >> ~/.shell_aliases <<"EOF"
alias MarkdownTocRecursive='find . ! -path "*.git*" -name "*.md" | xargs -I {} markdown-toc -i {}'
EOF

cat >> ~/.vimrc <<"EOF"
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
EOF

cat >> ~/.vimrc <<"EOF"
function! g:RunCtrlPWithFilterInNewTab(query)
  let g:ctrlp_default_input=a:query
  execute '-tabnew'
  execute 'CtrlP'
  let g:ctrlp_default_input=''
endfunction
EOF

add_special_vim_map "cpfat" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr>test\')<cr>' 'ctrlp filename adding test'
add_special_vim_map "cpfrt" $':call RunCtrlPWithFilterInNewTab(\'<c-r>=expand("%:t:r")<cr><bs><bs><bs><bs><bs>\')<cr>' 'ctrlp filename removing test'
add_special_vim_map "ctit" $'? it(<cr>V$%y$%o<cr><c-c>Vpf(2l' 'test copy it test case content'
add_special_vim_map "ctde" $'? describe(<cr>V$%y$%o<cr><c-c>Vpf(2l' 'test copy describe test content'
add_special_vim_map "eeq" $'iXexpectEqual<c-o>:call feedkeys("<c-l>", "t")<cr>' 'test expect toEqual'
add_special_vim_map "sjsfun" "v/[^,] {<cr><right>%" "select js function"
add_special_vim_map "djsfun" "v/[^,] {<cr><right>%d" "cut js function"
add_special_vim_map 'tjmvs' 'I<c-right><right><c-c>viwy?describe(<cr>olet <c-c>pa;<c-c><c-o><left>v_<del>' \
  'jest move variable outside of it'
add_special_vim_map "titr" $'_ciwconst<c-c>/from<cr>ciw= require(<del><c-c>$a)<c-c>V:<c-u>%s/\%V\C;//g<cr>' \
  'transform import to require'
add_special_vim_map "jimc" "a.mock.calls<c-c>" "jest instert mock calls"
add_special_vim_map "jimi" "a.mockImplementation(() => )<left>" "jest instert mock implementation"
add_special_vim_map "jirv" "a.mockReturnValue()<left>" "jest instert mock return value"
add_special_vim_map 'ftcrefuntype' 'viwyi<c-right><left>: <c-c>pviwyO<c-c>Otype <c-c>pa = () => <c-c>4hi' 'typescript create function type'
add_special_vim_map "jrct" "gv:<c-u>%s/\%V\C+//ge<cr>:<c-u>%s/\%V\CObject //ge<cr>:<c-u>%s/\%V\CArray //ge<cr>:<c-u>%s/\%V\C\[Fun.*\]/expect.any(Function)/ge<cr>" \
  "jest replace copied text from terminal"

cat >> ~/.vim-macros <<"EOF"
" Convert jsx prop to object property
_f=i\<del>: \<c-c>\<right>%s,\<c-c>``s\<c-c>``j

" Create test property
_f:v$\<left>\<del>A: \<c-c>_viwyA''\<c-c>\<left>paValue\<c-c>A,\<c-c>_\<down>

" wrap type object in tag
i<\<c-c>\<right>%a>\<c-c>\<left>%\<left>
EOF

# requires jq by default
cat >> ~/.vimrc <<"EOF"
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
EOF

install_vim_package prettier/vim-prettier

if [ ! -f ~/.npm-completion ]; then
  npm completion > ~/.npm-completion
fi
cat ~/.npm-completion >> ~/.shellrc

install_omzsh_plugin lukechilds/zsh-better-npm-completion

if [ ! -d ~/.vim/bundle/coc.nvim/node_modules ]; then
  (cd ~/.vim/bundle/coc.nvim && yarn)
fi

install_vim_package neoclide/coc-html

cat >> ~/.zshrc <<"EOF"
export NODE_DISABLE_COLORS=1
EOF

# coc-eslint can be disabled due performance
# To remove: `CocUninstall coc-eslint`
# Confirm with: `CocList`
if [ ! -f ~/project/.config/without-coc-eslint ]; then
  install_vim_package neoclide/coc-eslint
  cat >> ~/.vimrc <<"EOF"
  call add(g:coc_global_extensions, 'coc-eslint')
EOF
fi

cat >> ~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-html')
EOF

# The filetypes and probe is to disable on Markdown
sed -i '$ d' ~/.vim/coc-settings.json
cat >> ~/.vim/coc-settings.json <<"EOF"
  ,
  "eslint.autoFixOnSave": true,
  "eslint.filetypes": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
  "eslint.probe": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
  "javascript.suggestionActions.enabled": false,
  "prettier.disableSuccessMessage": true
}
EOF

cat >> /tmp/expected-vscode-extensions <<"EOF"
dbaeumer.vscode-eslint
EOF

# js-extras available
# js-vue available
# ts available

# js END

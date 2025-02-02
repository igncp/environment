#!/usr/bin/env bash

set -e

. src/js/nodenv.sh
. src/js/react_native.sh
. src/js/ts.sh
. src/js/vue.sh
. src/js/yarn_workspaces.sh

install_node_modules() {
  local NAME="$1"
  local BIN="${2:-$NAME}"

  if [ ! -f "$HOME/.npm-packages/bin/$BIN" ] && type npm >/dev/null 2>&1; then
    echo "Installing node module: $NAME"
    npm i -g $NAME
  fi
}

provision_setup_js() {
  cat >~/.npmrc <<"EOF"
prefix = ${HOME}/.npm-packages
EOF

  provision_setup_nodenv

  cat >>~/.vimrc <<"EOF"
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
EOF

  cat >>~/.shellrc <<"EOF"
export PATH="$HOME/.npm-packages/bin:$PATH"
NPMVersions() { npm view $1 versions --json; } # NPMVersions react
EOF
  cat >>~/.zshrc <<"EOF"
export PATH="$HOME/.npm-packages/bin:$PATH"
EOF

  install_omzsh_plugin lukechilds/zsh-better-npm-completion

  if [ ! -f ~/.npm-completion ] && type npm >/dev/null 2>&1; then
    npm completion >~/.npm-completion
  fi
  cat ~/.npm-completion >>~/.shellrc

  # 由 nvim coc 用
  install_node_modules yarn

  # https://github.com/sgentle/caniuse-cmd
  install_node_modules caniuse-cmd caniuse

  install_node_modules graphql-language-service-cli graphql-lsp
  install_node_modules live-server
  install_node_modules tldr

  cat >>~/.shell_aliases <<"EOF"
Serve() { PORT="$2"; live-server --port="${PORT:=9000}" $1; }
alias PlaywrightTrace='npx playwright show-trace'

if type -a bun &>/dev/null; then
  alias BunUpgrade='bunx npm-check-updates -i'
fi
EOF

  cat >>/tmp/expected-vscode-extensions <<"EOF"
dbaeumer.vscode-eslint
EOF

  if [ -d ~/.local/share/nvim/lazy/markdown-preview.nvim/app ] &&
    [ ! -d ~/.local/share/nvim/lazy/markdown-preview.nvim/app/node_modules ]; then
    echo "Installing markdown-preview.nvim dependencies"
    cd ~/.local/share/nvim/lazy/markdown-preview.nvim/app
    yarn
  fi

  provision_setup_js_ts
  provision_setup_js_vue
  provision_setup_js_yarn_workspaces
  provision_setup_react_native
}

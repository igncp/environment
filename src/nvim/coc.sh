#!/usr/bin/env bash

set -e

provision_setup_nvim_coc() {
  # ctrl-w,ctrl-p: move to floating window
  # - To remove an extension after installed, comment lines and then: :CocUninstall coc-name
  # - To open multiple references at once: enter in visual mode inside the quickfix window and select multiple
  # - Press `t` to open each case in new tab, press `enter` to open each file (unless already opened) in new tab

  install_nvim_package neoclide/coc.nvim

  cat >>~/.vimrc <<"EOF"
let g:coc_global_extensions = []
nnoremap <silent> K :call CocAction('doHover')<CR>

inoremap <silent><expr> <C-j> coc#pum#visible() ? coc#pum#next(1) : "\<C-j>"
inoremap <silent><expr> <C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)

nnoremap <silent> <leader>dd :<C-u>CocList diagnostics<cr>
nnoremap <leader>dc :CocList commands<cr>
nnoremap <leader>de :CocEnable<cr>
nnoremap <leader>dE :CocDisable<cr>
nnoremap <leader>ds :CocCommand<cr>
nnoremap <leader>dl <Plug>(coc-codelens-action)
nnoremap <leader>do <Plug>(coc-codeaction)
nnoremap <leader>dr <Plug>(coc-rename)
nnoremap <leader>dv <Plug>(coc-refactor)
command! -nargs=? Fold :call CocAction('fold', <f-args>)

call add(g:coc_global_extensions, 'coc-snippets')
call add(g:coc_global_extensions, 'coc-sh')
call add(g:coc_global_extensions, 'coc-git')
call add(g:coc_global_extensions, 'coc-lists')
call add(g:coc_global_extensions, 'coc-sumneko-lua')
call add(g:coc_global_extensions, 'coc-yaml')
call add(g:coc_global_extensions, 'coc-docker')

let g:coc_snippet_next = '<c-d>'

nnoremap <nowait><expr> <C-g> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <nowait><expr> <C-g> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"

call add(g:coc_global_extensions, 'coc-json')
EOF

  if [ ! -d ~/.local/share/nvim/lazy/coc.nvim/node_modules ]; then
    (cd ~/.local/share/nvim/lazy/coc.nvim && npm i) || true
  fi

  cat >>~/.vimrc <<"EOF"
call add(g:coc_global_extensions, 'coc-html')

" https://github.com/neoclide/coc-css#install
" autocmd FileType scss setl iskeyword+=@-@

call add(g:coc_global_extensions, 'coc-tsserver')

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact

if executable('pip')
  call add(g:coc_global_extensions, 'coc-pyright')
endif
EOF

  cat >~/.vim/coc-settings.json <<"EOF"
{
  "suggest.noselect": true,
  "coc.preferences.jumpCommand": "tab drop",
  "coc.preferences.formatOnSave": true,
  "[markdown]": {
    "coc.preferences.formatOnSave": false
  },
  "diagnostic.enableHighlightLineNumber": false,
  "Lua.workspace.checkThirdParty": false,
  "diagnostic.errorSign": "E",
  "diagnostic.infoSign": "I",
  "diagnostic.warningSign": "W",
  "git.enableGutters": false,
  "list.normalMappings": {
    "<C-j>": "command:CocNext",
    "<C-k>": "command:CocPrev"
  },
  "snippets.userSnippetsDirectory": "$HOME/.vim-snippets",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "javascript.updateImportsOnFileMove.enabled": "always",
  "python.formatting.provider": "ruff",
  "python.linting.ruffEnabled": true,
  "languageserver": {
    "graphql": {
      "command": "graphql-lsp",
      "args": ["server", "-m", "stream"],
      "filetypes": ["graphql","typescript", "typescriptreact"]
    },
    "nix": {
      "command": "nil",
      "filetypes": ["nix"]
    },
    "kotlin": {
      "command": "$HOME/nix-dirs/.kotlin-language-server/server/build/install/server/bin/kotlin-language-server",
      "filetypes": ["kotlin"]
    },
    "terraform": {
      "command": "terraform-ls",
      "args": ["serve"],
      "filetypes": [
        "terraform",
        "tf"
      ],
      "initializationOptions": {},
      "settings": {}}},
    "snippets.ultisnips.pythonPrompt": false
}
EOF

  # coc-eslint can be disabled due performance
  # To remove: `CocUninstall coc-eslint`
  # Confirm with: `CocList`

  if [ ! -f "$PROVISION_CONFIG"/coc-eslint-skip ]; then
    echo "call add(g:coc_global_extensions, 'coc-eslint')" >>~/.vimrc
    echo "call add(g:coc_global_extensions, 'coc-stylelint')" >>~/.vimrc
  fi

  if [ -f "$PROVISION_CONFIG"/tailwind ]; then
    echo "call add(g:coc_global_extensions, '@yaegassy/coc-tailwindcss3')" >>~/.vimrc
  fi

  # To try:
  # - https://github.com/tjdevries/coc-zsh
  # - https://github.com/iamcco/coc-diagnostic
  # - https://github.com/neoclide/coc-jest

  if [ -f "$PROVISION_CONFIG"/coc-prettier ]; then
    echo "call add(g:coc_global_extensions, 'coc-prettier')" >>~/.vimrc
  fi

  provision_append_json ~/.vim/coc-settings.json '
"sumneko-lua.enableNvimLuaDev": true,
"Lua.hint.enable": false,
"typescript.suggestionActions.enabled": false,
"eslint.probe": ["javascript", "javascriptreact", "typescript", "typescriptreact", "vue"],
"javascript.suggestionActions.enabled": false,
"eslint.autoFixOnSave": false
'
}

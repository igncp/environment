execute pathogen#infect()
filetype plugin indent on
syntax on

" fix control + arrows
  set term=xterm

" prevent saving backup files
  set nobackup
  set noswapfile

" support all hex colors (e.g. for syntastic)
  set  t_Co=256

set clipboard=unnamedplus
set number
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set cursorline
set autoindent

" remove autoindentation when pasting
  set pastetoggle=<F2>

" neocomplete
  let g:neocomplete#enable_at_startup = 1

let g:vim_markdown_folding_disabled = 1
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:NERDSpaceDelims = 1


" syntastic
  let g:syntastic_mode_map = { 'mode': 'active',
                            \ 'active_filetypes': ['python', 'javascript'],
                            \ 'passive_filetypes': [] }
  set statusline+=%#warningmsg#
  set statusline+=%{SyntasticStatuslineFlag()}
  set statusline+=%*
  let g:syntastic_always_populate_loc_list = 1
  let g:syntastic_auto_loc_list = 1
  let g:syntastic_check_on_open = 1
  let g:syntastic_check_on_wq = 0
  let g:syntastic_javascript_checkers = ['eslint']
  let g:syntastic_json_checkers=[]
  highlight link SyntasticErrorSign SignColumn
  highlight link SyntasticWarningSign SignColumn
  highlight link SyntasticStyleErrorSign SignColumn
  highlight link SyntasticStyleWarningSign SignColumn
  let g:syntastic_error_symbol = '❌'
  let g:syntastic_style_error_symbol = '⁉️'
  hi Error ctermbg=lightred ctermfg=black
  hi SpellBad ctermbg=lightred ctermfg=black

map ,e :e <C-R>=expand("%:p:h") . "/" <CR>

" change to current file directory
  nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

" run macro on d
  nnoremap <Space> @d

inoremap <C-e> <Esc>A
inoremap <C-a> <Esc>I

" save file shortcuts
  nmap <C-s> :update<Esc>
  inoremap <C-s> <Esc>:update<Esc>i<right>

" copy - paste between files
  vmap <leader>y :w! /tmp/vitmp<CR>
  nmap <leader>p :r! cat /tmp/vitmp<CR>

" check haskell on save and open (eagletmt/ghcmod-vim)
  " autocmd BufWritePost *.hs :GhcModCheckAsync
  " autocmd BufReadPost *.hs :GhcModCheckAsync

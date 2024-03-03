#!/usr/bin/env bash

set -e

provision_setup_c() {
  # astyle: http://astyle.sourceforge.net/astyle.html

  cat >>~/.vimrc <<"EOF"
autocmd Filetype c,cc setlocal softtabstop=4 tabstop=4 shiftwidth=4
autocmd filetype c,cc :exe 'vnoremap <leader>kks yOprintf("P: %s\n", P);<c-c>FP;vpgvy$FPvp_'
autocmd filetype c,cc :exe "nnoremap <silent> <leader>kb :!astyle --style=allman --indent-after-parens %<cr>:e<cr>"
autocmd filetype c,cc set iskeyword-=-
EOF

  cat >>~/.shell_aliases <<"EOF"
if type gdbgui &>/dev/null; then
  alias GdbGui='gdbgui -p 9002 --host 0.0.0.0'
fi
EOF

}

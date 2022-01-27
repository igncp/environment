# c START

# astyle: http://astyle.sourceforge.net/astyle.html

install_system_package ctags

if ! type clib > /dev/null 2>&1 ; then
  echo "installing clib"
  sudo rm -rf /tmp/clib
  git clone https://github.com/clibs/clib.git /tmp/clib
  cd /tmp/clib
  sudo make install
fi

cat >> ~/.vimrc <<"EOF"
  autocmd Filetype c,cc setlocal softtabstop=4 tabstop=4 shiftwidth=4
  autocmd filetype c,cc :exe 'vnoremap <leader>kks yOprintf("P: %s\n", P);<c-c>FP;vpgvy$FPvp_'
  autocmd filetype c,cc :exe "nnoremap <silent> <leader>kb :!astyle --style=allman --indent-after-parens %<cr>:e<cr>"
  autocmd filetype c,cc set iskeyword-=-
EOF

cat >> ~/.shell_aliases <<"EOF"
alias GdbGui='gdbgui -p 9002 --host 0.0.0.0'
EOF

if ! type gdbgui > /dev/null 2>&1 ; then
  pip install gdbgui
fi

if ! type gcovr > /dev/null 2>&1 ; then
  pip install gcovr
fi

# c END

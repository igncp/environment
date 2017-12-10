# c START

# astyle: http://astyle.sourceforge.net/astyle.html

if ! type clib > /dev/null 2>&1 ; then
  echo "installing clib"
  sudo rm -rf /tmp/clib
  git clone https://github.com/clibs/clib.git /tmp/clib
  cd /tmp/clib
  sudo make install
fi

cat >> ~/.vimrc <<"EOF"
  autocmd Filetype c setlocal softtabstop=4 tabstop=4 shiftwidth=4
  autocmd filetype c :exe 'vnoremap <leader>kks yOprintf("P: %s\n", P);<c-c>FP;vpgvy$FPvp_'
  autocmd filetype c :exe "nnoremap <silent> <leader>kb :!astyle --style=allman -xU0 %<cr>:e<cr>"
EOF

# c END

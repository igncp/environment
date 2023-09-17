#!/usr/bin/env bash

set -e

provision_setup_c() {
  if [ ! -f "$PROVISION_CONFIG"/c ]; then
    return
  fi

  # astyle: http://astyle.sourceforge.net/astyle.html

  install_system_package ctags

  if ! type clib >/dev/null 2>&1; then
    echo "Installing clib"
    sudo rm -rf /tmp/clib
    git clone https://github.com/clibs/clib.git /tmp/clib
    cd /tmp/clib
    sudo make install
  fi

  cat >>~/.vimrc <<"EOF"
autocmd Filetype c,cc setlocal softtabstop=4 tabstop=4 shiftwidth=4
autocmd filetype c,cc :exe 'vnoremap <leader>kks yOprintf("P: %s\n", P);<c-c>FP;vpgvy$FPvp_'
autocmd filetype c,cc :exe "nnoremap <silent> <leader>kb :!astyle --style=allman --indent-after-parens %<cr>:e<cr>"
autocmd filetype c,cc set iskeyword-=-
EOF

  cat >>~/.shell_aliases <<"EOF"
alias GdbGui='gdbgui -p 9002 --host 0.0.0.0'
EOF

  # # This currently has an error on install
  # if !context.system.get_has_binary("gdbgui") {
  #   System::run_bash_command("pip install gdbgui");
  # }

  if ! type gcovr >/dev/null 2>&1; then
    pip install gcovr
  fi
}

# custom START

cat >> ~/.bashrc <<"EOF"
EOF

cat >> ~/.bash_aliases <<"EOF"
EOF

cat >> ~/.vimrc <<"EOF"
let g:hardtime_default_on = 0
call SetColors()

cat >> ~/.vimrc <<"EOF"
function! SetupEnvironment()
  let l:path = expand('%:p')
  if l:path =~ '/home/igncp/foo/bar'
    let g:Fast_grep='lib'
  elseif l:path =~ '/home/igncp/bar/baz'
    let g:Fast_grep='main'
  else
    let g:Fast_grep='src'
  endif
endfunction
autocmd! BufReadPost,BufNewFile * call SetupEnvironment()
EOF

# Inter-VM communication
mkdir -p ~/vms
cat >> ~/.bash_aliases <<"EOF"
VMSSH() { cd ~/vms; ssh IP_OF_VM; }
VMUpload() { rsync --delete -rh -e ssh "${@:3}" "$1" IP_OF_VM:/home/igncp/vms/"$2" ; }
VMDownload() { rsync --delete -rh -e ssh "${@:3}" IP_OF_VM:"$1" /home/igncp/vms/"$2"; }
EOF

# ttyd
  if ! type ttyd > /dev/null 2>&1 ; then
    wget https://github.com/tsl0922/ttyd/releases/download/1.4.4/ttyd_linux.x86_64
    sudo mv ttyd_linux.x86_64 /usr/bin/ttyd
  fi

  # Remember to update PORT,USERNAME,PASS
  cat >> ~/.bash_aliases <<"EOF"
  # Copy selection shortcut is: Ctrl + Insert
  # https://github.com/xtermjs/xterm.js/blob/3.12.0/typings/xterm.d.ts#L26
  # Configured fornt in browser: Monaco
  TTYD() {
    TTYD_Stop; TTYD_Stop; TTYD_Stop; ttyd \
      -p PORT \
      -c USERNAME:PASS \
      -t fontSize=18 \
      -t fontFamily='Monospace' \
      -t lineHeight='1.2px' \
      --once \
      "$@" \
      bash -x
  }

  TTYD_Stop() {
    TMUX_PID=$(sudo netstat -ltnp | grep PORT | grep -Eo [0-9]*/tmux | grep -o [0-9]*)
    SSH_PID=$(sudo netstat -ltnp | grep PORT | grep -Eo [0-9]*/ssh | grep -o [0-9]*)

    echo "PID TMUX: $TMUX_PID . PID SSH: $SSH_PID"

    sudo kill "$TMUX_PID"; sudo kill "$SSH_PID"
  }
EOF

# custom END

echo "finished provisioning"

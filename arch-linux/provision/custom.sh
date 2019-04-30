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

if ! type ttyd > /dev/null 2>&1 ; then
  wget https://github.com/tsl0922/ttyd/releases/download/1.4.4/ttyd_linux.x86_64
  sudo mv ttyd_linux.x86_64 /usr/bin/ttyd
fi

cat >> ~/.bash_aliases <<"EOF"
# https://github.com/xtermjs/xterm.js/blob/3.12.0/typings/xterm.d.ts#L26
TTYD() {
  ttyd \
    -p PORT \
    -c USERNAME:PASS \
    -t fontSize=18 \
    --once \
    bash -x
}
EOF

# custom END

echo "finished provisioning"

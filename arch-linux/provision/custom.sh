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
mkdir -p ~/.sftp
cat >> ~/.bash_aliases <<"EOF"
VMSSH() { cd ~/.sftp; ssh IP_OF_VM; }
SFTPUpload() { sftp IP_OF_VM:/home/igncp/.sftp <<< 'put '"$1" ; }
EOF

# custom END

echo "finished provisioning"

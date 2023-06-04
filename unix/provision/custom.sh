# custom START

update_vim_colors_theme

cat > /tmp/.vimrc <<"EOF"
function! SetupEnvironment()
  let l:path = expand('%:p')
  if l:path =~ '_HOME_/foo/bar'
    let g:Fast_grep='. --exclude-dir={node_modules,dist,.git,coverage} --exclude="*.log"'
  elseif l:path =~ '_HOME_/bar/baz'
    let g:Fast_grep='main'
  else
    let g:Fast_grep='src'
  endif
endfunction
autocmd! BufReadPost,BufNewFile * call SetupEnvironment()
EOF
sed -i 's|_HOME_|'"$HOME"'|g' /tmp/.vimrc
cat /tmp/.vimrc >> ~/.vimrc ; rm -rf /tmp/.vimrc

# custom END

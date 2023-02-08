# ts START

# Dependencies:
# - after: js.sh

cat >> ~/.vimrc <<"EOF"
autocmd FileType typescript :exe ConsoleMappingA
autocmd FileType typescript :exe ConsoleMappingB

" run eslint and prettier over file
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kb :!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <c-a> :update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "inoremap <silent> <c-a> <c-c>:update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  autocmd filetype typescript :exe "vnoremap <silent> <leader>kB :'<,'>PrettierFragment<cr>"
EOF

cat > /tmp/colors.vim <<"EOF"
hi tsxTagName ctermfg=91 cterm=bold
hi tsxIntrinsicTagName ctermfg=91 cterm=bold
hi tsxAttrib cterm=bold
EOF
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|=91|=153|' /tmp/colors.vim
fi
cat /tmp/colors.vim >> ~/.vim/colors.vim ; rm /tmp/colors.vim

cat >> ~/.vimrc <<"EOF"
function! RunTsMorph(fileName)
  call writefile(getreg('i', 1, 1), "/tmp/vimTsMorph.ts")
  call system('(cd ~/.ts-morph && node build/src/' . a:fileName . '.js "/tmp/vimTsMorph.ts")')
  let l:fileContent = readfile("/tmp/vimTsMorph.ts")
  call setreg('i', l:fileContent, 'c')
  if col('.') == 1
    execute 'normal! "ip'
  else
    execute 'normal! "iP'
  endif
endfunction
vnoremap <leader>le "id:call RunTsMorph('arrow-to-fn')<CR>
EOF

cat >> ~/.shell_aliases <<"EOF"
alias TsMorfCopyFromHomeIntoProject='bash ~/.ts-morph/copy_into_project.sh'
alias TsMorfCopyFromProjectIntoHome='bash ~/project/scripts/ts-morph/copy_into_home.sh'
alias TsMorfCopyFromProjectIntoEnvironment='rsync -rhv --delete ~/project/scripts/ts-morph/ ~/development/environment/unix/scripts/ts-morph/'
alias TsMorfCopyFromEnvironmentIntoProjectAndHome='rsync -rhv --delete ~/development/environment/unix/scripts/ts-morph/ ~/project/scripts/ts-morph/ && TsMorfCopyFromProjectIntoHome'
EOF

# ts END

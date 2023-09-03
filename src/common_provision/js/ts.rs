use crate::base::{config::Theme, Context};

pub fn run_ts(context: &mut Context) {
    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
autocmd FileType typescript :exe ConsoleMappingA
autocmd FileType typescript :exe ConsoleMappingB

" run eslint and prettier over file
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kb :!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <c-a> :update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "inoremap <silent> <c-a> <c-c>:update<cr>:!eslint --fix %<cr>:e<cr>"
  autocmd filetype typescript :exe "nnoremap <silent> <leader>kB :!npx prettier --write %<cr>:e<cr>"
  autocmd filetype typescript :exe "vnoremap <silent> <leader>kB :'<,'>PrettierFragment<cr>"

function! RunTsMorph(fileName, rest)
  call writefile(getreg('i', 1, 1), "/tmp/vimTsMorph.tsx")
  call system('(cd ~/.ts-morph && node build/src/' . a:fileName . '.js "/tmp/vimTsMorph.tsx" ' . a:rest . ')')
  let l:fileContent = readfile("/tmp/vimTsMorph.tsx")
  call setreg('i', l:fileContent, 'c')
  if col('.') == 1
    execute 'normal! "ip'
  else
    execute 'normal! "iP'
  endif
endfunction

vnoremap <leader>le "id:call RunTsMorph('arrow-to-fn')<CR>
vnoremap <leader>li "id:call RunTsMorph('jsx-el', 'div a')<CR>
"###,
    );

    let mut new_colors = r###"
hi tsxTagName ctermfg=91 cterm=bold
hi tsxIntrinsicTagName ctermfg=91 cterm=bold
hi tsxAttrib cterm=bold
"###
    .to_string();

    if context.config.theme == Theme::Dark {
        new_colors = new_colors.replace("=91", "=153");
    }

    context.files.append(
        &context.system.get_home_path(".vim/colors.vim"),
        &new_colors,
    );

    context.home_append(
        ".shell_aliases",
        r###"
TSMorphSyncToEnvironment() {
  rsync --delete -rhv \
    --exclude build \
    --exclude node_modules \
      ~/.ts-morph/ \
      ~/development/environment/unix/scripts/ts-morph/
}

TSMorphSyncToHome() {
  printf "Are you sure? [Y/n] "
  read -r -q "response?"
  if [[ $response =~ "^(y|Y)" ]]; then
    rsync --delete -rhv \
      --exclude build \
      --exclude node_modules \
        ~/development/environment/unix/scripts/ts-morph/ \
        ~/.ts-morph/
    (cd ~/.ts-morph/ \
        && npm install \
        && npm run build \
        && npm test )
  else
    echo "Not copying because didn't reply with confirmation"
  fi
}
"###,
    );
}

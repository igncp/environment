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
}

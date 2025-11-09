" Don't copy when using del
vnoremap <Del> "_d
nnoremap <Del> "_d

nnoremap r gt
nnoremap R gT
nnoremap <c-t> :tabnew<cr>:e <left><right>

nnoremap Q @q

" Replace with selection. To replace by current register, use <c-r>0 to paste it
vmap <leader>g "ay:%s/\C\<<c-r>a\>//g<left><left>
vmap <leader>G "ay:%s/\C<c-r>a//g<left><left>

" Fill the search bar with current text and allow to edit it
vnoremap <leader>/ y/<c-r>"
nnoremap <leader>/ viwy/<c-r>"

" Folding
set foldlevelstart=20
set foldmethod=indent
set fml=0
nnoremap <leader>fr :set foldmethod=manual<cr>
nnoremap <leader>fR :set foldmethod=indent<cr>
vnoremap <leader>ft <c-c>:set foldmethod=manual<cr>mlmk`<kmk`>jmlggvG$zd<c-c>'kVggzf'lVGzfgg<down>
nnoremap <leader>; za
onoremap <leader>; <C-C>za
vnoremap <leader>; zf

nnoremap <leader>A ggVG$
cnoremap <c-A> <Home>
cnoremap <c-E> <End>

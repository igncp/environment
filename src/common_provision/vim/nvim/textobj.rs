use crate::base::Context;

use super::install::{add_special_vim_map, install_vim_package};

pub fn run_nvim_textobj(context: &mut Context) {
    install_vim_package(context, "glts/vim-textobj-comment", None);
    install_vim_package(context, "kana/vim-textobj-indent", None);
    install_vim_package(context, "kana/vim-textobj-user", None);
    install_vim_package(context, "wellle/targets.vim", None);

    // Examples: https://github.com/kana/vim-textobj-user/wiki

    context.files.append(
        &context.system.get_home_path(".vimrc"),
        r###"
" regular expressions that match numbers (order matters .. keep '\d' last!)
" note: \+ will be appended to the end of each
let s:regNums = [ '0b[01]', '0x\x', '\d' ]

function! s:inNumber()
	" select the next number on the line
	" this can handle the following three formats (so long as s:regNums is
	" defined as it should be above this function):
	"   1. binary  (eg: "0b1010", "0b0000", etc)
	"   2. hex     (eg: "0xffff", "0x0000", "0x10af", etc)
	"   3. decimal (eg: "0", "0000", "10", "01", etc)
	" NOTE: if there is no number on the rest of the line starting at the
	"       current cursor position, then visual selection mode is ended (if
	"       called via an omap) or nothing is selected (if called via xmap)

	" need magic for this to work properly
	let l:magic = &magic
	set magic

	let l:lineNr = line('.')

	" create regex pattern matching any binary, hex, decimal number
	let l:pat = join(s:regNums, '\+\|') . '\+'

	" move cursor to end of number
	if (!search(l:pat, 'ce', l:lineNr))
		" if it fails, there was not match on the line, so return prematurely
		return
	endif

	" start visually selecting from end of number
	normal! v

	" move cursor to beginning of number
	call search(l:pat, 'cb', l:lineNr)

	" restore magic
	let &magic = l:magic
endfunction

function! CurrentLineA()
  normal! 0
  let head_pos = getpos('.')
  normal! $
  let tail_pos = getpos('.')
  return ['v', head_pos, tail_pos]
endfunction

function! CurrentLineI()
  normal! ^
  let head_pos = getpos('.')
  normal! g_
  let tail_pos = getpos('.')
  let non_blank_char_exists_p = getline('.')[head_pos[2] - 1] !~# '\s'
  return
  \ non_blank_char_exists_p
  \ ? ['v', head_pos, tail_pos]
  \ : 0
endfunction

" Mappings:
xnoremap <silent> iN :<c-u>call <sid>inNumber()<cr>
onoremap <silent> iN :<c-u>call <sid>inNumber()<cr>
call textobj#user#plugin('line', {
\   '-': {
\     'select-a-function': 'CurrentLineA',
\     'select-a': 'al',
\     'select-i-function': 'CurrentLineI',
\     'select-i': 'il',
\   },
\ })
autocmd User targets#mappings#user call targets#mappings#extend({
    \ 'a': { 'argument': [{'o': '[({[]', 'c': '[]})]', 's': ','}] }
    \ })

" glts/vim-textobj-comment: ic , ac, iC
"###,
    );

    add_special_vim_map(
        context,
        [
            "showtabnumber",
            r#":echo tabpagenr()<cr>"#,
            "show tab number",
        ],
    )
}

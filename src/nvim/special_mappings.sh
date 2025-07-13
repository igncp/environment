# These maps will be present in a fzf list (apart from working normally)
# They must begin with <leader>zm (where <leader> == <Space>)
add_special_vim_map() {
  local MAP_KEYS_AFTER_LEADER="$1"
  local MAP_END="$2"
  local MAP_COMMENT="$3"
  local MAP_TYPE="${4:-nnoremap}"

  cat >>"$HOME/.vimrc" <<EOF
$MAP_TYPE <leader>zm$MAP_KEYS_AFTER_LEADER $MAP_END
EOF

  cat >>"$HOME/.special-vim-maps-from-provision.txt" <<EOF
<Space>zm$MAP_KEYS_AFTER_LEADER -- $MAP_COMMENT
EOF
}

#!/usr/bin/env bash

set -euo pipefail

provision_setup_nvim_special_mappings() {
  echo '' >~/.special-vim-maps-from-provision.txt

  add_special_vim_map 'renameexisting' ':Rename <c-r>=expand("%:t")<cr>' 'rename existing file'
  add_special_vim_map 'showabsolutepath' ':echo expand("%:p")<cr>' 'show absolute path of file'
  add_special_vim_map 'showrelativepath' ':echo @%<cr>' 'show relative path of file'
  add_special_vim_map 'addprops' '_f(li{}: Props <c-c>kitype Props = {<cr>}<c-c>jf}i' 'add props type to function component'
  add_special_vim_map \
    'jrct' \
    'gv:<c-u>%s/\%V\C+//ge<cr>:<c-u>%s/\%V\CObject //ge<cr>:<c-u>%s/\%V\CArray //ge<cr>:<c-u>%s/\%V\C\[Fun.*\]/expect.any(Function)/ge<cr>' \
    'jest replace copied text from terminal'
  add_special_vim_map 'showtabnumber' ':echo tabpagenr()<cr>' 'show tab number'

  add_special_vim_map 'translationjsx' \
    "vitS}lvi}S)lvi)S'hit('<c-c>2lvlc,<c-c>hi" 'translation for jsx content' 'nmap'
  add_special_vim_map 'translationdquotes' \
    'va"S}lvi}S)it<right>,<left>' 'translation for prop with double quotes' 'nmap'
}

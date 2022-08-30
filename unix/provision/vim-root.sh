# vim-root START

# This can be different in MacOS
ROOT_HOME=$(eval echo "~root")
echo '" # This file was generated from ~/project/provision/provision.sh' > /tmp/.vimrc
cat >> /tmp/.vimrc <<"EOF"
syntax off
set number
filetype plugin indent on
let mapleader = "\<Space>"
set mouse-=a
vnoremap <Del> "_d
nnoremap <Del> "_d
nnoremap Q @q
nnoremap r gt
nnoremap R gT
EOF
sudo mv /tmp/.vimrc "$ROOT_HOME"/.vimrc

# vim-root END

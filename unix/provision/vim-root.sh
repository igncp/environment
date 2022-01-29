# vim-root START

echo '" # This file was generated from ~/project/provision/provision.sh' > /tmp/.vimrc
sudo mv /tmp/.vimrc /root/.vimrc

sudo cp /root/.vimrc /tmp/.vimrc
sudo chown igncp /tmp/.vimrc
cat >> /tmp/.vimrc <<"EOF"
syntax off
set number

" sort indent block. requires nmap. requires 2 plugins.
  nmap <leader>kl vii:sort<cr>
  " same as above but for objects without comma in the last item
  nmap <leader>hj  movii<c-c>A,<c-c>_vii:sort<cr>vii<c-c>A<backspace><c-c>`o
EOF
sudo mv /tmp/.vimrc /root/.vimrc

# vim-root END

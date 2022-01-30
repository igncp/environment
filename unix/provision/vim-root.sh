# vim-root START

echo '" # This file was generated from ~/project/provision/provision.sh' > /tmp/.vimrc
sudo mv /tmp/.vimrc /root/.vimrc

sudo cp /root/.vimrc /tmp/.vimrc
sudo chown igncp /tmp/.vimrc
cat >> /tmp/.vimrc <<"EOF"
syntax off
set number
filetype plugin indent on
let mapleader = "\<Space>"
EOF
sudo mv /tmp/.vimrc /root/.vimrc

# vim-root END

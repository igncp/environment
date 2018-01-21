# go START

# remember to run :GoInstallBinaries inside vim

cat >>~/.bashrc <<"EOF"
export GOROOT=/home/$USER/.go
export GOPATH=/home/$USER/.go-workspace
export GOBIN=$GOROOT/bin
export GO15VENDOREXPERIMENT=1
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
EOF

if ! type go >/dev/null 2>&1; then
  echo "installing go"
  cd ~
  mkdir -p ~/.go-workspace
  curl -O https://storage.googleapis.com/golang/go1.7.3.linux-amd64.tar.gz
  sudo tar -zxf go1*
  sudo chown -R $USER ~/go
  mv ~/go ~/.go
  rm -rf ~/go1*
  sudo wget https://raw.github.com/kura/go-bash-completion/master/etc/bash_completion.d/go \
    -O /usr/share/bash-completion/completions/go
  . ~/.bashrc >/dev/null 2>&1
fi

install_go_package() {
  if [ ! -d ~/.go-workspace/src/"$1" ]; then
    echo "installing go package $1"
    go get -u "$1"
  fi
}

install_go_package github.com/golang/lint/golint
install_go_package github.com/kisielk/errcheck

if ! type shfmt >/dev/null 2>&1; then
  go get -u mvdan.cc/sh/cmd/shfmt
fi

install_vim_package fatih/vim-go

cat >>~/.vimrc <<"EOF"
let g:syntastic_go_checkers = ['go', 'golint', 'govet']
set rtp+=$GOPATH/src/github.com/golang/lint/misc/vim
let g:go_list_type = "quickfix"

autocmd filetype sh :exe "nnoremap <silent> <leader>kb :!shfmt -w -i 2 %<cr>:e<cr>"
EOF

# go END

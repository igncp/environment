# misc START

if [ ! -d ~/english-words ]; then
  git clone https://github.com/dwyl/english-words ~/english-words
fi


clone_example_from_gh() {
  PARENT_PATH=~/examples/$1
  DIR=$(echo $2 | sed -r "s|(.+)/(.+)|\1_-_\2|") # foo/bar => foo_-_bar
  FULL_PATH=$PARENT_PATH/$DIR
  if [ ! -d $FULL_PATH ]; then
    REPO_URL=https://github.com/$2.git
    COMMIT=$3
    mkdir -p $PARENT_PATH
    git clone $REPO_URL $FULL_PATH
    cd $FULL_PATH
    git reset --hard $COMMIT > /dev/null 2>&1
    cd - > /dev/null 2>&1
  fi
}

# github issues
  if ! type ghi > /dev/null 2>&1; then
    curl -sL https://raw.githubusercontent.com/stephencelis/ghi/master/ghi > ghi && \
      chmod 755 ghi && \
      sudo mv ghi /usr/local/bin
  fi
  echo 'ghiIssueFolded() { tmux split-window -h;
    tmux select-pane -t 0; tmux resize-pane -x 60;
    ghi show $1 > /tmp/$1; tmux kill-pane -t 1; }' >> ~/.bash_aliases

# cron job
  # https://crontab.guru
  crontab <<"EOF"
*/15 * * * * /project/scripts/MyScript.sh
EOF

# ufw
  install_pacman_package ufw
  if [[ ! -z $(sudo ufw status | grep inactive) ]]; then
    sudo ufw enable
    sudo ufw allow ssh
    sudo ufw allow 80
    sudo ufw logging medium # /var/log/ufw.log
  fi
  echo 'alias UfwStatus="sudo ufw status verbose"' >> ~/.bash_aliases

# heroku toolbelt (requires ruby)
  if ! type heroku > /dev/null 2>&1 ; then
    wget -O- https://toolbelt.heroku.com/install-ubuntu.sh | sh
  fi

# ssh keys
  echo 'eval `ssh-agent -s` > /dev/null 2>&1' >> ~/.bashrc
  add_ssh() {
    echo "if [ -f ~/.ssh/$1 ]; then ssh-add ~/.ssh/$1 > /dev/null 2>&1; fi" >> ~/.bashrc
  }
  # add_ssh foo

# convenient alias to expand (ctrl-alt-e)
  mkdir -p ~/diffs
  cat >> ~/.bash_aliases <<"EOF"
alias GD='git diff > ~/diffs/'
alias GA='git apply ~/diffs/'
EOF

# ssh greeting and session message
  cat >> ~/.bash_aliases <<"EOF"
alias SSHRestart='sudo systemctl restart sshd.service'
EOF
  cat > /tmp/greeting.txt <<"EOF"

  你好!

EOF
  sudo cp /tmp/greeting.txt /etc/motd
  sudo sed -i "s|#PrintLastLog no|PrintLastLog no|" /etc/ssh/sshd_config
  if [ ! -f ~/.check-files/ssh ]; then
    sudo systemctl restart sshd.service
    mkdir -p ~/.check-files && touch ~/.check-files/ssh
  fi
  cat >> ~/.bash_sources <<"EOF"
echo ""
echo "  -> task list"
task list
EOF

# geeknote: requires python2
if ! type geeknote > /dev/null 2>&1 ; then
  cd ~; sudo rm -rf geeknote
  git clone https://github.com/jeffkowalski/geeknote
  sudo pip2 install lxml proxyenv
  cd geeknote
  sudo python2 setup.py install
  cd ~; sudo rm -rf geeknote
  geeknote settings --editor "$EDITOR"
fi

# useful fonts: https://github.com/ryanoasis/nerd-fonts#patched-fonts
  # using monofur at the moment

# exercism
install_from_aur exercism https://aur.archlinux.org/exercism-cli.git

# mp4 utils
if ! type mp4info > /dev/null 2>&1 ; then
  rm -rf /tmp/mp4info; mkdir /tmp/mp4info; cd /tmp/mp4info
  # https://www.bento4.com/downloads/
  wget http://zebulon.bok.net/Bento4/binaries/Bento4-SDK-1-5-1-622.x86_64-unknown-linux.zip
  unzip ./*.zip
  rm ./*.zip
  mv ./* bento4
  sudo mv bento4/bin/* /usr/bin/
  cd ~;  rm -rf /tmp/mp4info
fi

# languagetool
if [ ! -d /usr/lib/languagetool ]; then
  cd ~; sudo rm -rf /usr/lib/languagetool
  curl -L https://git.io/vNqdP | sudo bash
  sudo mv LanguageTool* /usr/lib/languagetool
  sudo chown -R $USER:$USER /usr/lib/languagetool
fi
mkdir -p /usr/lib/languagetool/bin
cat > /usr/lib/languagetool/bin/languagetool <<"EOF"
#!/usr/bin/env bash

echo "wrapper in /usr/lib/languagetool/bin/languagetool"
if [ "$#" -eq 0 ]; then
  DEFAULT_ARGS=''
else
  DEFAULT_ARGS='-d EN_QUOTES,DASH_RULE'
  echo "default args: $DEFAULT_ARGS"
  echo ""
fi
eval 'java -jar /usr/lib/languagetool/languagetool-commandline.jar '"$DEFAULT_ARGS $@";
EOF
chmod +x /usr/lib/languagetool/bin/languagetool
echo 'export PATH=$PATH:/usr/lib/languagetool/bin' >> ~/.bashrc
cat >> ~/.vimrc <<"EOF"
let s:LanguageToolMap=':tabnew /tmp/languagetool<cr>ggVGp:x<cr>:-tabnew\|te
  \ /usr/lib/languagetool/bin/languagetool /tmp/languagetool \| less<cr>'
execute 'vnoremap <leader>hl y' . s:LanguageToolMap
execute 'nnoremap <leader>hl ggVGy<c-o>' . s:LanguageToolMap
EOF

# git-chglog
if ! type chglog > /dev/null 2>&1 ; then
  curl -s https://api.github.com/repos/git-chglog/git-chglog/releases/latest \
    | grep browser_download_url \
    | grep linux_amd64 \
    | grep -oP 'h.*64' \
    | wget -i - \
    && mv git-chglog_* chglog \
    && chmod +x chglog \
    && sudo mv chglog /usr/bin/
fi

# misc END
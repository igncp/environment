# general-extras START

set -e

install_pacman_package at
install_pacman_package ctags
install_pacman_package feh # image previews
install_pacman_package ranger
install_pacman_package strace

sudo atd

install_pacman_package netdata
if [[ ! -z $(sudo systemctl status netdata.service | grep inactive) ]]; then
  sudo systemctl restart netdata.service
fi

cat > ~/.ctags <<"EOF"
--regex-make=/^([^# \t]*):/\1/t,target/
--langdef=markdown
--langmap=markdown:.mkd
--regex-markdown=/^#[ \t]+(.*)/\1/h,Heading_L1/
--regex-markdown=/^##[ \t]+(.*)/\1/i,Heading_L2/
--regex-markdown=/^###[ \t]+(.*)/\1/k,Heading_L3/
EOF

install_pacman_package task
cat >> ~/.bash_aliases <<"EOF"
alias t='task'
EOF
cat >> ~/.bash_sources <<"EOF"
source_if_exists /usr/share/doc/task/scripts/bash/task.sh # to have _task available
complete -o nospace -F _task t
EOF

install_pacman_package shellcheck
echo 'SHELLCHECK_IGNORES="SC1090"' >> ~/.bashrc
add_shellcheck_ignores() {
  for DIRECTIVE in "$@"; do
    echo 'SHELLCHECK_IGNORES="$SHELLCHECK_IGNORES,SC'"$DIRECTIVE"'"' >> ~/.bashrc
  done
}
add_shellcheck_ignores 2016 2028 2046 2059 2086 2088 2143 2164 2181 1117
echo 'export SHELLCHECK_OPTS="-e $SHELLCHECK_IGNORES"' >> ~/.bashrc

install_pacman_package graphviz dot
cat > ~/.dot-script.sh <<"EOF2"
  FILE_PATH=$1
  EXTENSION=$2
  FNAME="${FILE_PATH::-4}" # remove .dot extension
  RELATIVE=$(python -c "import os.path; print(os.path.relpath('$FNAME', '$PWD'))")
  dot "$FILE_PATH" -T"$EXTENSION" > "$FNAME"."$EXTENSION" && \
  printf "created ${GREEN}$RELATIVE."$EXTENSION"${NC}\n"
EOF2
chmod +x ~/.dot-script.sh
cat >> ~/.bash_aliases <<"EOF"
_DotRecursiveWatch() {
  EXTENSION=$1
  USED_DIR=${2:-.}
  printf "looking recursively in: ${BLUE}$USED_DIR${NC}\n"
  while true; do # when a file is added, entr will exit
    sleep 1
    find "$USED_DIR" -type f -name "*.dot" | entr -d ~/.dot-script.sh /_ "$EXTENSION"
  done
}
DotPNGRecursiveWatch() {
  _DotRecursiveWatch png $@
}
DotSVGRecursiveWatch() {
  _DotRecursiveWatch svg $@
}
DotJPGRecursiveWatch() {
  _DotRecursiveWatch jpg $@
}
EOF

cat > ~/.m4-script.sh <<"EOF2"
  FILE_PATH="$1"
  RESULT_EXTENSION="$2"
  FNAME="${FILE_PATH::-3}" # remove .m4 extension
  RELATIVE=$(python -c "import os.path; print(os.path.relpath('$FNAME', '$PWD'))")
  m4 "$FILE_PATH" > "$FNAME"."$RESULT_EXTENSION" && \
  printf "created ${GREEN}$RELATIVE."$RESULT_EXTENSION"${NC}\n"
EOF2
chmod +x ~/.m4-script.sh
cat >> ~/.bash_aliases <<"EOF"
M4RecursiveWatch() {
  RESULT_EXTENSION="$1"
  USED_DIR="${2:-.}"
  printf "looking recursively in: ${BLUE}$USED_DIR${NC}\n"
  while true; do # when a file is added, entr will exit
    sleep 1
    find "$USED_DIR" -type f -name "*.m4" | entr -d ~/.m4-script.sh /_ "$RESULT_EXTENSION"
  done
}
EOF

if ! type entr > /dev/null 2>&1 ; then
  sudo rm -rf ~/_entr-tmp
  cd ~ && mkdir ~/_entr-tmp && cd ~/_entr-tmp
  curl -O https://bitbucket.org/eradman/entr/get/entr-3.6.tar.gz
  tar -zxvf ./*.tar.gz
  ENTR_DIR=$(find . -maxdepth 1 -mindepth 1 -type d) && cd $ENTR_DIR
  ./configure && make test && sudo make install
  cd ~ && sudo rm -rf ~/_entr-tmp
fi

if [ ! -f ~/hhighlighter/h.sh ] > /dev/null 2>&1 ; then
  rm -rf ~/hhighlighter
  git clone --depth 1 https://github.com/paoloantinori/hhighlighter.git ~/hhighlighter
fi
echo 'source_if_exists ~/hhighlighter/h.sh' >> ~/.bash_sources

if ! type sr > /dev/null 2>&1 ; then
  cd ~; rm -rf sr-tmp
  git clone https://github.com/igncp/sr.git sr-tmp --depth 1
  cd sr-tmp
  make
  sudo mv build/bin/sr /usr/bin
  cd ~ ; rm -rf sr-tmp
fi

# for gng2 key generation: sudo rngd -r /dev/urandom
install_pacman_package rng-tools rngd

cat >> ~/.bash_aliases <<"EOF"
TimeManualSet() {
  sudo systemctl stop systemd-timesyncd.service
  sudo timedatectl set-time "$1" # "yyyy-MM-DD HH:MM:SS"
}
alias TimeManualUnset='sudo systemctl restart systemd-timesyncd.service'
EOF

# network
  cat >> ~/.bash_aliases <<"EOF"
WifiConnect() {
  sudo wifi-menu
  sudo dhcpcd
}
EOF

# navi
  if ! type navi > /dev/null 2>&1 ; then
    sudo rm -rf /usr/lib/navi
    sudo git clone --depth 1 https://github.com/denisidoro/navi /usr/lib/navi
    sudo chown -R igncp:igncp /usr/lib/navi
    (cd /usr/lib/navi && sudo make install)
  fi

# tmux task

cat > /project/scripts/custom/tmux-task.sh <<"EOF"
#!/usr/bin/env bash

echo "$@" > /tmp/pane-cmd-content.sh

cat > /tmp/tmux-pane-cmd.sh <<"E2OF"
#!/usr/bin/env bash

rm -rf /tmp/pane-cmd-success

printf "Running ... '$(head /tmp/pane-cmd-content.sh)' in '$(basename $(pwd))'"

(sh /tmp/pane-cmd-content.sh && touch /tmp/pane-cmd-success) > /tmp/tmux-pane-cmd-log.txt 2>&1

if [ ! -f /tmp/pane-cmd-success ]; then
  HEIGHT=$(($(tmux display-message -p '#{client_height}') / 2))

  # tmux select-pane -t 1
  tmux resize-pane -t 1 -y "$HEIGHT"

  sleep 1

  less /tmp/tmux-pane-cmd-log.txt
fi
E2OF

tmux \
  split-window "sh /tmp/tmux-pane-cmd.sh" \
  && tmux resize-pane -t 1 -y 1 \
  && tmux select-pane -t 0
EOF

cat >> ~/.bash_aliases <<"EOF"
alias TmuxCmdLog='less /tmp/tmux-pane-cmd-log.txt'
alias TmuxTask='sh /project/scripts/custom/tmux-task.sh'
EOF

# general-extras END

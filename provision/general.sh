#!/usr/bin/env bash

chmod -R +x /project/scripts

cp_file_from_provision() { FILE=$1; TO_PATH=$2; cp /project/provision/$FILE $TO_PATH/$FILE; }

cp_file_from_provision .bashrc ~
cp_file_from_provision .tmux.conf ~
cp_file_from_provision .vimrc ~

mkdir -p ~/logs

if ! type jq > /dev/null  ; then
  echo "installing basic packages"
  sudo apt-get update
  sudo apt-get install -y curl git unzip ack-grep git-extras \
    build-essential python-software-properties tree jq

  git config --global user.email "foo@bar.com" && git config --global user.name "Foo Bar"
fi

# if [ ! -d ~/src ]; then cp -r /project/src ~; fi

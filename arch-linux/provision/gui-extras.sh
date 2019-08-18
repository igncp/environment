# gui-extras START

# alacritty
  intall_pacman_package alacritty
  check_file_exists /project/provision/alacritty.yml
  cp /project/provision/i3-config ~/.config/alacritty/alacritty.yml
  cat >> ~/.bash_aliases <<"EOF"
  alias ModifyAlacritty='$EDITOR /project/provision/alacritty.yml;
    cp /project/provision/alacritty.yml ~/.config/alacritty/alacritty.yml; echo "alacritty.yml copied"'
EOF

# eclim
  if [ ! -f ~/.check-files/eclim ]; then
    cd ~
    wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
    java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
    touch ~/.check-files/eclim
  fi

# vscode
  if ! type code > /dev/null 2>&1 ; then
    if [ -f /home/igncp/Downloads/vscode.tar.gz ]; then
      (cd /home/igncp/Downloads \
        && sudo rm -rf /usr/bin/code /opt/visual-studio-code /home/igncp/Downloads/VSCode-* \
        && tar xf vscode.tar.gz \
        && sudo mv VSCode-* /opt/visual-studio-code \
        && sudo ln -s /opt/visual-studio-code/bin/code /usr/bin/code \
        && rm -rf vscode.tar.gz)
    else
      echo "Not installing VS Code because the file '~/Downloads/vscode.tar.gz' is missing."
      echo "  https://code.visualstudio.com/#alt-downloads"
      exit 1
    fi
  fi

  cp /project/provision/vscode-settings.json /home/igncp/.config/Code/User/settings.json

# Automatic X server
  cat >> ~/.bashrc <<"EOF"
if ! xhost >& /dev/null && [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  exec startx
fi
EOF

# gui-extras END

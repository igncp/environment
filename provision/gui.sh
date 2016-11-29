# gui START

if [ ! -f ~/.check-files/gui ]; then
  echo "installing gui"
  sudo apt-get update
  sudo apt-get install -y xfce4
  sudo sed -i "s|allowed_users=.*$|allowed_users=anybody|" /etc/X11/Xwrapper.config
  sudo apt-get install -y xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
  sudo /usr/share/debconf/fix_db.pl
  startxfce4&
  curl -o ~/.git-prompt.sh \
    https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
  xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 20
  mkdir -p ~/.check-files && touch ~/.check-files/gui
fi

cat >> ~/.bash_aliases <<"EOF"
alias StartXFCE4='startxfce4&'
alias XFCE4SettingsEditor='xfce4-settings-editor'
EOF
echo "source_if_exists ~/.git-prompt.sh" >> ~/.bash_sources

install_apt_package terminator
cat > ~/.config/terminator/config <<"EOF"
[global_config]
  title_transmit_bg_color = "#82a7b2"
[keybindings]
[profiles]
  [[default]]
    palette = "#073642:#dc322f:#859900:#b58900:#268bd2:#d33682:#2aa198:#eee8d5:#002b36:#cb4b16:#586e75:#657b83:#839496:#6c71c4:#93a1a1:#fdf6e3"
    background_image = None
    use_system_font = False
    foreground_color = "#ffffff"
    font = Liberation Mono 13
    cursor_blink = False
[layouts]
[plugins]
EOF

if [ ! -f ~/.check-files/eclim ]; then
  cd ~
  wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
  java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
  touch ~/.check-files/eclim
fi

# gui END

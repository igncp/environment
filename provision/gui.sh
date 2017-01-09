# gui START

if [ ! -f ~/.check-files/gui ]; then
  echo "installing gui"
  sudo pacman -S --noconfirm xfce4 xfce4-goodies
  mkdir -p ~/.check-files && touch ~/.check-files/gui
fi
sudo bash -c 'echo "allowed_users=anybody" > /etc/X11/Xwrapper.config'
sudo bash -c 'echo "needs_root_rights=yes" >> /etc/X11/Xwrapper.config'
cat >> ~/.bash_aliases <<"EOF"
alias StartXFCE4='startxfce4&'
alias XFCE4SettingsEditor='xfce4-settings-editor'
SetupXFCE4() {
  xfconf-query -c xfce4-panel -p /panels/panel-1/size -s 25
  xfconf-query -c xfce4-desktop -np '/desktop-icons/style' -t 'int' -s '0'
}
EOF

# terminator
  install_pacman_package terminator
  mkdir -p ~/.config/terminator
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

install_pacman_package chromium
install_pacman_package gimp

sudo pacman -S --noconfirm ttf-freefont ttf-arphic-uming ttf-baekmuk # fonts for chromium

if [ ! -f ~/.check-files/gui-fonts ]; then
  sudo pacman -S --noconfirm ttf-freefont ttf-arphic-uming ttf-baekmuk # fonts for chromium
  mkdir -p ~/.check-files; touch ~/.check-files/gui-fonts
fi

# gui END

# gui-extras START

# eclim
  if [ ! -f ~/.check-files/eclim ]; then
    cd ~
    wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
    java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
    touch ~/.check-files/eclim
  fi

# gui-extras END

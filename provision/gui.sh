# gui START

if [ ! -f ~/.check-files/gui ]; then
  echo "installing gui"
  sudo apt-get update
  sudo apt-get install -y xfce4
  sudo sed -i "s|allowed_users=.*$|allowed_users=anybody|" /etc/X11/Xwrapper.config
  sudo apt-get install -y xfce4 virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11
  sudo /usr/share/debconf/fix_db.pl
  startxfce4&
  mkdir -p ~/.check-files && touch ~/.check-files/gui
fi

cat >> ~/.bash_aliases <<"EOF"
alias StartXFCE4='startxfce4&'
EOF

cat >> ~/.bash_aliases <<"EOF"
alias StartEclipse='nohup /opt/eclipse/eclipse > /dev/null 2>&1&'
EOF

if [ ! -f ~/.check-files/eclim ]; then
  cd ~
  wget https://github.com/ervandew/eclim/releases/download/2.6.0/eclim_2.6.0.jar
  java -Dvim.files=$HOME/.vim -Declipse.home=/opt/eclipse -jar eclim_2.6.0.jar install
  touch ~/.check-files/eclim
fi

# gui END

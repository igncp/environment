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

if [ ! -d /opt/eclipse ]; then
  cd ~
  wget http://www.eclipse.org/downloads/download.php?file=/eclipse/downloads/drops4/R-4.2.1-201209141800/eclipse-SDK-4.2.1-linux-gtk-x86_64.tar.gz
  mv down* eclipse.tar.gz
  cp eclipse.tar.gz eclipse-copy.tar.gz
  tar -zxvf eclipse.tar.gz
  sudo mv eclipse /opt
fi

cat >> ~/.bash_aliases <<"EOF"
alias StartEclipse='nohup /opt/eclipse/eclipse > /dev/null 2>&1&'
EOF

# gui END

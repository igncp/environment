# ubuntu-gui-desktop START

if [ ! -f ~/.check-files/ubuntu-gui-desktop ]; then
  sudo apt-get update
  sudo apt-get install -y ubuntu-desktop

  # Disable the automatic GUI start
  sudo systemctl set-default multi-user

  touch ~/.check-files/ubuntu-gui-desktop
fi

# ubuntu-gui-desktop END

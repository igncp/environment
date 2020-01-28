# ubuntu-final START

install_system_package build-essential make

cat >> ~/.bash_aliases <<"EOF"
alias WifiConnect='nmtui'
EOF

# black screen after boot
# - On booting, press `Esc` to enter the GRUB screen
# - Press `e` on the `Ubuntu` line to enter the Edit Mode
# - Change `ro quiet splash` by `nomodeset quiet splash`
if [ ! -f ~/.check-files/lightdm ] ; then
  sudo apt-get install -y lightdm
  mkdir -p ~/.check-files && touch ~/.check-files/lightdm
  dkpg-reconfigure lightdm
fi

# ubuntu-final END

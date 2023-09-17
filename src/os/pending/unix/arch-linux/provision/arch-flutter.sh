# @TODO
# arch-flutter START

if [ ! -f ~/.check-files/flutter ]; then
  sudo pacman -S --noconfirm lib32-gcc-libs
  touch ~/.check-files/flutter
fi

# arch-flutter END

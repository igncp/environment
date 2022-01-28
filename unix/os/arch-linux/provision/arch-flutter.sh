# arch-flutter START

if [ ! -f ~/.check-files/flutter ]; then
  sudo pacman -S --noconfirm lib32-gcc-libs
  mkdir -p ~/.check-files && touch ~/.check-files/flutter
fi

# arch-flutter END

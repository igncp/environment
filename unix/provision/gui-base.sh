# gui-base START

cat > ~/.set-background.sh <<"EOF"
feh --bg-fill "$1"
cat ~/.fehbg | grep --color=never -o '\/home\/.*jpg' | sed 's|^|Image: |'
EOF
chmod +x ~/.set-background.sh
cat > ~/.scripts/wallpaper_update.sh <<"EOF"
if [ -d _HOME_/.config/variety/Downloaded ]; then
  find _HOME_/.config/variety/Downloaded/ -type f -name *.jpg | shuf -n 1 | xargs -I {} sh ~/.set-background.sh {}
fi
EOF
sed -i "s|_HOME_|$HOME|g" ~/.scripts/wallpaper_update.sh
chmod +x ~/.scripts/wallpaper_update.sh
cat >> ~/.shellrc <<"EOF"
alias WallpaperPrintCurrent="cat ~/.fehbg | grep --color=never -o '\/home\/.*jpg'"
EOF

check_file_exists ~/project/provision/fonts.conf
mkdir -p ~/.config/fontconfig
cp ~/project/provision/fonts.conf ~/.config/fontconfig
echo 'alias FontsList="fc-list"' >> ~/.shell_aliases

# GTK
  # https://www.gnome-look.org/browse/ord/rating/
  # Can run: lxappearance # including inside Rofi
  # Themes:
    # If downloaded and `.tar.xz` file, uncompress with `tar -xf ...`
    # Move the directory inside `~/.themes/`
  # Icons: Don't uncompress the file, import it directly from lxappearance
  # Currently using:
    # - Cursors: Comix (use the opaque) - https://www.gnome-look.org/p/999996/
    # - Icons: Flatery - https://www.gnome-look.org/s/Gnome/p/1332404
    # - Theme: Prof-Gnome-theme - https://www.gnome-look.org/p/1334194/
    # - Grub: Tela - https://www.gnome-look.org/p/1307852/

# Keyboard Setup (not only Arch): https://wiki.archlinux.org/index.php/X_keyboard_extension

# keyboard
cat >> ~/.shell_aliases <<"EOF"
alias KeyboardLayoutGB='setxkbmap -layout gb'
alias KeyboardLayoutUS='setxkbmap -layout us'
alias KeyboardLayoutES='setxkbmap -layout es' # accents work when also enabling ibus
alias KeyboardQuery='setxkbmap -query'
alias KeyboardListKeys='xmodmap -pke'
alias KeyboardRefreshConfig='sh ~/.keyboard-config.sh'

alias XKBCompDump='xkbcomp $DISPLAY /tmp/xkb-config.xkb'
alias XKBCompLoad='xkbcomp /tmp/xkb-config.xkb $DISPLAY'
EOF

# change caps to esc
cat > /tmp/90-custom-kbd.conf <<"EOF"
Section "InputClass"
    Identifier "keyboard defaults"
    MatchIsKeyboard "on"

    Option "XKbOptions" "caps:escape"
EndSection
EOF
sudo mv /tmp/90-custom-kbd.conf /etc/X11/xorg.conf.d/

sed -i '1ish /etc/X11/xinit/xinitrc.d/50-systemd-user.sh' ~/.xinitrc

echo '' > ~/.scripts/gui_daemons.sh

# gui-i3 available
# gui-common available
# gui-extras available

# gui-base END

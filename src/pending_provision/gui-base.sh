# @TODO
# gui-base START

# change caps to esc
cat >/tmp/90-custom-kbd.conf <<"EOF"
Section "InputClass"
    Identifier "keyboard defaults"
    MatchIsKeyboard "on"

    Option "XKbOptions" "caps:escape"
EndSection
EOF
sudo mv /tmp/90-custom-kbd.conf /etc/X11/xorg.conf.d/

sed -i '1ish /etc/X11/xinit/xinitrc.d/50-systemd-user.sh' ~/.xinitrc

# gui-base END

# gui-lxde START

install_system_package lxde startlxde

echo 'exec startlxde' >> ~/.xinitrc

echo 'pcmanfm -w "$1"' > ~/.set-background.sh
chmod +x ~/.set-background.sh
sed -i '1isleep 5s && /home/igncp/wallpaper-update.sh 2>&1 > /dev/null &' ~/.xinitrc

# https://github.com/jnsh/arc-theme

echo 'Configure desktop icons and stretch and remove this message'

# gui-lxde END

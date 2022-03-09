# gui-lxde START

install_system_package lxde startlxde

echo 'exec startlxde' >> ~/.xinitrc

echo 'pcmanfm -w "$1"' > ~/.set-background.sh
chmod +x ~/.set-background.sh
sed -i '1isleep 5s && /home/igncp/wallpaper-update.sh 2>&1 > /dev/null &' ~/.xinitrc

if [ ! -f ~/.check-files/lxde-configure ]; then
  # https://github.com/jnsh/arc-theme
  echo '[~/.check-files/lxde-configure] Configure panel (autohide), desktop icons and stretch and remove this message'
fi

# http://xahlee.info/linux/linux_lxde_add_key_shortcuts.html
if [ -z "$(grep 'W-q' ~/.config/openbox/lxde-rc.xml || true)" ]; then
  echo 'Add the W-q (windows + q) to keyboard shortcuts for rofi'
  cat > /tmp/rofi-shortcut <<"EOF"
<keybind key="W-q">
    <action name="Execute">
      <command>rofi -show combi -font 'hack 20' -combi-modi drun,window,ssh -theme-str 'window { background-color:#ccf;}'</command>
    </action>
</keybind>
EOF
  cat /tmp/rofi-shortcut
fi
cat >> ~/.shell_aliases <<"EOF"
alias LXDEReload='echo "Remember to run in guest"; openbox-lxde --reconfigure'
EOF


# gui-lxde END

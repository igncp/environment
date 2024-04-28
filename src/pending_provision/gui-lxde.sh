# @TODO
# gui-lxde START

echo 'pcmanfm -w "$1"' >~/.scripts/set_background.sh
chmod +x ~/.scripts/set_background.sh
sed -i "1i(sleep 5s && $HOME/.scripts/wallpaper_update.sh 2>&1 > /dev/null) &" ~/.xinitrc

# http://xahlee.info/linux/linux_lxde_add_key_shortcuts.html
if [ -z "$(grep 'W-q' ~/.config/openbox/lxde-rc.xml || true)" ]; then
  echo 'Add the W-q (windows + q) to keyboard shortcuts for rofi'
  cat >/tmp/rofi-shortcut <<"EOF"
<keybind key="W-q">
    <action name="Execute">
      <command>rofi -show combi -font 'hack 20' -combi-modi drun,window,ssh -theme-str 'window { background-color:#ccf;}'</command>
    </action>
</keybind>
EOF
  cat /tmp/rofi-shortcut
fi

if [ -z "$(grep 'arandr' ~/.config/lxpanel/LXDE/panels/panel || true)" ]; then
  echo 'Update the ~/.config/lxpanel/LXDE/panels/panel config with at least the following (LXDEPanelConfig):'
  echo 'Plugin {
  type=launchbar
  Config {
    Button {
      id=pcmanfm.desktop
    }
    Button {
      id=lxterminal.desktop
    }
    Button {
      id=arandr.desktop
    }
  }
}'
fi

# gui-lxde END

# gui-lxde START

install_system_package lxde startlxde

echo 'exec startlxde' >> ~/.xinitrc

echo 'pcmanfm -w "$1"' > ~/.set-background.sh
chmod +x ~/.set-background.sh
sed -i "1i(sleep 5s && $HOME/.scripts/wallpaper_update.sh 2>&1 > /dev/null) &" ~/.xinitrc

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
alias LXDEPanelRestart='DISPLAY=:0 lxpanelctl restart'
alias LXDEPanelConfig='nvim ~/.config/lxpanel/LXDE/panels/panel && DISPLAY=:0 lxpanelctl restart'
EOF

if [ -f ~/.config/pcmanfm/LXDE/pcmanfm.conf ]; then
  sed -i 's|maximized=.*|maximized=1|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
  sed -i 's|show_hidden=.*|show_hidden=1|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
  sed -i 's|view_mode=.*|view_mode=list|' ~/.config/pcmanfm/LXDE/pcmanfm.conf
fi

if [ -f ~/.config/lxpanel/LXDE/panels/panel ]; then
  sed -i 's|autohide=.*|autohide=1|' ~/.config/lxpanel/LXDE/panels/panel
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

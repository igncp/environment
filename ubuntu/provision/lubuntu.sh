# lubuntu START

cat >> ~/.bash_aliases <<"EOF"
LXPANEL_FILE="$HOME/.config/lxpanel/Lubuntu/panels/panel"
alias LubuntuPanelSetAutohide='sed -i "s/  autohide=.$/  autohide=1/" "$LXPANEL_FILE" && lxpanelctl restart'
alias LubuntuPanelSetNoAutohide='sed -i "s/  autohide=.$/  autohide=0/" "$LXPANEL_FILE" && lxpanelctl restart'
EOF

cat > ~/.update-display.sh <<"EOF"
#!/usr/bin/env bash

IS_DISCONNECTED=$(xrandr | grep HDMI | grep disconnected)

if [ -n "$IS_DISCONNECTED" ]; then
  notify-send "Enabling laptop display"

  xrandr \
    --output eDP-1 --auto \
    --primary \
    --output HDMI-1 --off
else
  notify-send "Enabling HDMI display"

  xrandr \
    --output HDMI-1 --auto \
    --primary \
    --output eDP-1 --off
fi
EOF

echo 'Update the hotkeys to run `sh /home/igncp/.update-display` on Shift+Alt+M and remove this message'

# lubuntu END

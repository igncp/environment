# @TODO
# gui-i3 START

if [ -f ~/.config/i3/config ]; then
  HAS_TO_RELOAD_I3=$(ag 'systemctl suspend' ~/.config/i3/config)
else
  HAS_TO_RELOAD_I3=''
fi
if [ -f ~/development/environment/project/.config/standard-i3 ]; then
  sed -i '/gaps/d' ~/.config/i3/config
fi
if [ "$ENVIRONMENT_THEME" == "dark" ]; then
  sed -i 's|background #.*|background #333333|' ~/.config/i3/config
  sed -i 's|statusline #.*|statusline #ffffff|' ~/.config/i3/config
fi

# I3 needs terminal emulator (e.g. terminator from gui-common) and may require custom fonts (e.g. arch-gui)

if type dunst >/dev/null 2>&1; then
  add_desktop_common \
    'dunstctl set-paused true' 'disable_notifications' 'Disable Notifications'

  add_desktop_common \
    'dunstctl set-paused false; notify-send "Time"' 'enable_notifications' 'Enable Notifications'
fi

# These require `polkit`, which is a dependency for example for `lightdm`
if [ -f ~/development/environment/project/.config/inside ]; then
  sed -i -r '/mod\+Shift\+o/ s|exec ".*"|exec "systemctl suspend"|' ~/.config/i3/config
else
  sed -i -r '/mod\+Shift\+o/ s|exec ".*"|exec "systemctl poweroff"|' ~/.config/i3/config
  if [ -n "$HAS_TO_RELOAD_I3" ]; then i3-msg restart; fi
fi

# Quick VNC shortcut (replace NAME and HOST)
#   cat > ~/.scripts/quick_vnc_NAME.sh <<"EOF"
# set -e
# if [ -n "$(ps aux | ag localhost | ag -v '\bag\b' | ag -v HOST)" ]; then
#   MSG="$(ps aux | ag -v '\bag\b' | ag 5900 | awk '{ printf $2" "; for(i=11;i<=NF;++i) printf $i" "; }')"
#   i3-nagbar -t warning -m "There is a different tunnel in place: $MSG"
#   return
# fi
# if [ -z "$(ps aux | ag localhost | ag HOST)" ]; then
#   alacritty -e sh -c 'echo "Creating tunnel" ; ssh -Nf -L 5900:localhost:5900 HOST'
# fi
# vncviewer localhost
# EOF
#   add_desktop_common \
#     "sh $HOME/.scripts/quick_vnc_NAME.sh" 'quick_vnc_NAME' 'NAME VNC'

# Copy SSH remote clipboard into the guest one (replace HOST)
# cat > ~/.scripts/ssh_clipboard.sh <<"EOF"
# alacritty -e sh -c 'ssh HOST "DISPLAY=:0 xclip -o -selection c" > /tmp/clip ; copyq copy "$(cat /tmp/clip)" ; rm /tmp/clip'
# EOF
# chmod +x ~/.scripts/ssh_clipboard.sh
# echo 'bindsym $mod+p exec "sh ~/.scripts/ssh_clipboard.sh"' >> ~/.config/i3/config

# gui-i3 END

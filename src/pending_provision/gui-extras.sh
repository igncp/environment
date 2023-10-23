# @TODO
# gui-extras START

# Automatic X server (don't use if using lightdm)
cat >>~/.bashrc <<"EOF"
if ! xhost >& /dev/null && [ -z "$SSH_CLIENT" ] && [ -z "$SSH_TTY" ]; then
  exec startx
fi
EOF

# Check `src/scripts/misc/vlc_playlist.sh`
install_system_package vlc

install_system_package android-file-transfer

install_system_package gnucash
if [ ! -f ~/.check-files/gnucash ]; then
  sudo pacman -S --noconfirm gnucash-docs

  touch ~/.check-files/gnucash
fi

# EBooks
install_system_package calibre
# [Arch]: After installing it may need:
# [Arch]: sudo pacman -Syu ; pip install neovim

# Update display with xrandr
# Custom resolution: https://askubuntu.com/a/377944
mkdir -p ~/.displays
cat >~/.displays/laptop.sh <<"EOF"
#!/usr/bin/env bash

xrandr \
  --output DP-2 \
    --primary \
    --mode 1920x1080 \
    --pos 0x0 \
    -s 0 \
  --output HDMI-0 \
    --off

notify-send "Just laptop"
EOF
cat >~/.displays/same.sh <<"EOF"
#!/usr/bin/env bash

if [ -n "$(xrandr | grep HDMI | grep disconnected)" ]; then
  sh ~/.displays/laptop.sh
else
  xrandr \
    --output DP-2 \
      --primary \
      --mode 1920x1080 \
      --pos 0x0 \
      -s 0 \
      --rotate normal \
    --output HDMI-0 \
      --mode 1920x1080 \
      --pos 0x0 \
      -s 0 \
      --rotate normal
  notify-send "HDMI same"
fi
EOF
cat >~/.displays/right.sh <<"EOF"
#!/usr/bin/env bash

if [ -n "$(xrandr | grep HDMI | grep disconnected)" ]; then
  sh ~/.displays/laptop.sh
else
  xrandr \
    --output HDMI-0 \
      --primary \
      -s 0 \
      --mode 1920x1080 \
      --pos 1920x0 \
      --rotate normal \
    --output DP-2 \
      -s 0 \
      --primary \
      --mode 1920x1080 \
      --pos 0x0 \
      --rotate normal
  notify-send "HDMI right"
fi
EOF
chmod -R +x ~/.displays

install_system_package chromium
cat >>~/.shell_aliases <<"EOF"
# useful to disable CORS without extensions
alias ChromiumWithoutSecurity='chromium --user-data-dir="~/chrome-without-security" --disable-web-security & exit'
alias ChromiumIncognito='chromium -incognito & exit'
alias Chromium='chromium & exit'
EOF

# https://github.com/kraanzu/termtyper
if ! type termtyper >/dev/null 2>&1; then
  pip install preferredsoundplayer
  python3 -m pip install git+https://github.com/kraanzu/termtyper.git
fi

# gui-extras END

# misc START

if [ ! -d ~/english-words ]; then
  git clone https://github.com/dwyl/english-words ~/english-words
fi

# ssh greeting and session message
  cat >> ~/.shell_aliases <<"EOF"
alias SSHRestart='sudo systemctl restart sshd.service'
EOF
  cat > /tmp/greeting.txt <<"EOF"

  你好!

EOF
  sudo cp /tmp/greeting.txt /etc/motd
  sudo sed -i "s|#PrintLastLog no|PrintLastLog no|" /etc/ssh/sshd_config
  if [ ! -f ~/.check-files/ssh ]; then
    sudo systemctl restart sshd.service
    touch ~/.check-files/ssh
  fi
  cat >> ~/.shell_sources <<"EOF"
echo ""
echo "  -> task list"
task list
EOF

# useful fonts: https://github.com/ryanoasis/nerd-fonts#patched-fonts
  # using monofur at the moment

# exercism
install_from_aur exercism https://aur.archlinux.org/exercism-cli.git

# mp4 utils
if ! type mp4info > /dev/null 2>&1 ; then
  rm -rf /tmp/mp4info; mkdir /tmp/mp4info; cd /tmp/mp4info
  # https://www.bento4.com/downloads/
  wget http://zebulon.bok.net/Bento4/binaries/Bento4-SDK-1-5-1-622.x86_64-unknown-linux.zip
  unzip ./*.zip
  rm ./*.zip
  mv ./* bento4
  sudo mv bento4/bin/* /usr/bin/
  cd ~;  rm -rf /tmp/mp4info
fi

# languagetool
if [ ! -d /usr/lib/languagetool ]; then
  cd ~; sudo rm -rf /usr/lib/languagetool
  curl -L https://git.io/vNqdP | sudo bash
  sudo mv LanguageTool* /usr/lib/languagetool
  sudo chown -R $USER:$USER /usr/lib/languagetool
fi
mkdir -p /usr/lib/languagetool/bin
cat > /usr/lib/languagetool/bin/languagetool <<"EOF"
#!/usr/bin/env bash

echo "wrapper in /usr/lib/languagetool/bin/languagetool"
if [ "$#" -eq 0 ]; then
  DEFAULT_ARGS=''
else
  DEFAULT_ARGS='-d EN_QUOTES,DASH_RULE'
  echo "default args: $DEFAULT_ARGS"
  echo ""
fi
eval 'java -jar /usr/lib/languagetool/languagetool-commandline.jar '"$DEFAULT_ARGS $@";
EOF
chmod +x /usr/lib/languagetool/bin/languagetool
echo 'export PATH=$PATH:/usr/lib/languagetool/bin' >> ~/.shellrc
cat >> ~/.vimrc <<"EOF"
let s:LanguageToolMap=':tabnew /tmp/languagetool<cr>ggVGp:x<cr>:-tabnew\|te
  \ /usr/lib/languagetool/bin/languagetool /tmp/languagetool \| less<cr>'
execute 'vnoremap <leader>hl y' . s:LanguageToolMap
execute 'nnoremap <leader>hl ggVGy<c-o>' . s:LanguageToolMap
EOF

# scc: performant cloc with extra info
if ! type scc > /dev/null 2>&1 ; then
  (cd ~ && \
    curl -s https://api.github.com/repos/boyter/scc/releases/latest \
      | grep unknown-linux \
      | grep browser \
      | grep 86_64 \
      | cut -d : -f 2,3 \
      | tr -d \" \
      | xargs wget
    unzip scc*64*.zip
    rm scc*.zip
    sudo mv scc /usr/bin)
fi

install_system_package pdfgrep

# latex
  install_system_package texlive-most pdflatex
  install_vim_package vim-latex/vim-latex

# brightness
  # https://wiki.archlinux.org/index.php/Backlight#ACPI
  cat >> ~/.shell_aliases <<"EOF"
BrightnessIntel() { echo "$1" | sudo tee /sys/class/backlight/intel_backlight/brightness; }
BrightnessIntelCat() { cat /sys/class/backlight/intel_backlight/brightness; }
BrightnessIntelMax() { cat /sys/class/backlight/intel_backlight/max_brightness; }
EOF
  cat >> ~/.shell_aliases <<"EOF"
BrightnessNV() { echo "$1" | sudo tee /sys/class/backlight/nv_backlight/brightness; }
BrightnessNVMax() { cat /sys/class/backlight/nv_backlight/max_brightness; }
EOF

# Automatic clone - Update for different providers / directories
  clone_dev_github_repo() {
    DIR_NAME="$HOME/development/$1";

    if [ ! -d "$DIR_NAME" ]; then
      git clone "git@github.com:igncp/$1.git" "$DIR_NAME"
    fi
  }

  clone_dev_github_repo environment

# Touchpad
  # xinput list # find devices
  # xinput list-props DEVICE_ID # find driver
  # TOUCHPAD_ID=$(xinput list | ag touchpad | awk '{ print $6 }' | grep -o '[0-9]*')
  # xinput set-button-map "$TOUCHPAD_ID" 1 0 3 4 5 6 7
    # The ID is from xinput list # https://unix.stackexchange.com/questions/438725/disabling-middle-click-on-bottom-of-a-clickpad-touchpad
  # Symantec:
    # echo 'synclient MaxTapTime=0' >> ~/.bashrc
    # echo 'synclient VertEdgeScroll=0' >> ~/.bashrc
    # echo 'synclient VertTwoFingerScroll=0' >> ~/.bashrc

# For encrypted devices
cat >> ~/.shell_aliases <<"EOF"
MountEncryptedDeviceNAME() {
  CRYPT_NAME="CRYPT_NAME"
  DEVICE_PATH="/dev/sdaX"
  MOUNT_POINT="$HOME/POINT"

  sudo cryptsetup open "$DEVICE_PATH" "$CRYPT_NAME"
  mkdir -p "$MOUNT_POINT"
  sudo mount "/dev/mapper/$CRYPT_NAME" "$MOUNT_POINT"
}
UmountEncryptedDeviceNAME() {
  CRYPT_NAME="CRYPT_NAME"
  MOUNT_POINT="$HOME/POINT"

  sudo umount "$MOUNT_POINT"
  sudo cryptsetup close "$CRYPT_NAME"
}
EOF

# prettier on save using autocommand instead of coc-prettier
cat >> ~/.vimrc <<"EOF"
autocmd BufWritePost *.tsx,*.js silent!
  \ execute "!npx prettier --write <afile>" | :e! <afile>
EOF

# HP Envy Printer setup
# https://www.cups.org/doc/options.html
if [ ! -f ~/.check-files/hp-printer ]; then
  sudo pacman -S --noconfirm cups
  sudo systemctl enable cups --now
  sudo pacman -S --noconfirm avahi
  sudo systemctl enable avahi-daemon --now
  sudo pacman -S --noconfirm nss-mdns
  sudo sed -i '/^hosts:/ s|myhostname resolve|myhostname mdns_minimal [NOTFOUND=return] resolve|' /etc/nsswitch.conf
  # sudo lpinfo -v # Confirm that the printer is found over network
  sudo sed -i '/SystemGroup sys root wheel$/ s|$| igncp|' /etc/cups/cups-files.conf; sudo systemctl restart cups
  # - Open the CUPS web interface in `http://localhost:631`
    # - Click `Administration > Add new printer` At this point, in the options it show the printer discovered
    # - Choose the first one discovered, the one with `dnssd` in the url protocol
    # - As model can choose `IPP Everywhere`
  # - At this point the printer should be able to print a test page
  # - In Chrome, when choosing print, need to click in `"See more"` the first time
  touch ~/.check-files/hp-printer
fi

# misc END

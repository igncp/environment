# misc START

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
  sudo sed -i '/SystemGroup sys root wheel$/ s|$| '"$USER"'|' /etc/cups/cups-files.conf; sudo systemctl restart cups
  # - Open the CUPS web interface in `http://localhost:631`
    # - Click `Administration > Add new printer` At this point, in the options it show the printer discovered
    # - Choose the first one discovered, the one with `dnssd` in the url protocol
    # - As model can choose `IPP Everywhere`
  # - At this point the printer should be able to print a test page
  # - In Chrome, when choosing print, need to click in `"See more"` the first time
  touch ~/.check-files/hp-printer
fi

if ! type sr > /dev/null 2>&1 ; then
  cd ~; rm -rf sr-tmp
  git clone https://github.com/igncp/sr.git sr-tmp --depth 1
  cd sr-tmp
  make
  sudo mv build/bin/sr /usr/bin
  cd ~ ; rm -rf sr-tmp
fi

install_system_package at
install_system_package ctags

cat > ~/.ctags <<"EOF"
--regex-make=/^([^# \t]*):/\1/t,target/
--langdef=markdown
--langmap=markdown:.mkd
--regex-markdown=/^#[ \t]+(.*)/\1/h,Heading_L1/
--regex-markdown=/^##[ \t]+(.*)/\1/i,Heading_L2/
--regex-markdown=/^###[ \t]+(.*)/\1/k,Heading_L3/
EOF

install_system_package shellcheck
echo 'SHELLCHECK_IGNORES="SC1090"' >> ~/.bashrc
add_shellcheck_ignores() {
  for DIRECTIVE in "$@"; do
    echo 'SHELLCHECK_IGNORES="$SHELLCHECK_IGNORES,SC'"$DIRECTIVE"'"' >> ~/.bashrc
  done
}
add_shellcheck_ignores 2016 2028 2046 2059 2086 2088 2143 2164 2181 1117
echo 'export SHELLCHECK_OPTS="-e $SHELLCHECK_IGNORES"' >> ~/.bashrc

# misc END

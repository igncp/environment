# dart START

# Check jvm-extras for Android Studio configuration

if [ ! -f ~/.check-files/flutter ]; then
  sudo pacman -S --noconfirm lib32-gcc-libs
  mkdir -p ~/.check-files && touch ~/.check-files/flutter
fi

cat >> ~/.bashrc <<"EOF"
export PATH="$PATH:/home/igncp/flutter/bin"
export PATH="$PATH:/home/igncp/flutter/bin/cache/dart-sdk/bin"
export PATH="$PATH:/home/igncp/.pub-cache/bin"
EOF

install_vim_package dart-lang/dart-vim-plugin

install_pacman_package dart

if ! type stagehand > /dev/null 2>&1 ; then
  pub global activate stagehand
fi

# dart END

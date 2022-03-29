# dart START

cat >> ~/.bashrc <<"EOF"
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$PATH:$HOME/flutter/bin/cache/dart-sdk/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
EOF

install_vim_package dart-lang/dart-vim-plugin

install_system_package dart

if ! type stagehand > /dev/null 2>&1 ; then
  pub global activate stagehand
fi

# dart END

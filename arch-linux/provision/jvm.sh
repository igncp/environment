# jvm START

install_pacman_package jdk8-openjdk java

cat >> ~/.vimrc <<"EOF"
" https://github.com/Scuilion/gradle-syntastic-plugin.git
let g:syntastic_java_checkers=['javac']
let g:syntastic_java_javac_config_file_enabled = 1
EOF

# jvm END

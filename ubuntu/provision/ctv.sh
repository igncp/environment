# ctv START

# lg webos
  # Important: Ubuntu 14/16 is required
  # Download installation from: http://webostv.developer.lge.com/sdk/installation
  # Unzip and follow GUI installation
cat >> ~/.bashrc <<"EOF"
export PATH="$PATH:/usr/local/share/webOS_TV_SDK/CLI/bin"
EOF

# tizen studio
  # Install JDK and dependencies (TODO: Automate)
  # sudo add-apt-repository ppa:webupd8team/java ; sudo apt update; sudo apt install -y oracle-java8-installer
  # sudo apt-get install -y rpm2cpio libwebkitgtk-1.0-0 expect gettext ruby

cat >> ~/.bashrc <<"EOF"
export PATH="$PATH:/home/igncp/tizen-studio/ide"
export PATH="$PATH:/home/igncp/tizen-studio/tools"
export PATH="$PATH:/home/igncp/tizen-studio/tools/ide/bin/"
EOF

# ctv END

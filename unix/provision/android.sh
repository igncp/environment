# android START

if [ ! -d ~/android-sdk ] && [ ! -d ~/android-studio ]; then
  echo 'Download android CLI tools (or Studio if necessary, not both)'
  echo 'Android CLI: structure should be ~/android-sdk/cmdline-tools/tools/bin/sdkmanager'
  echo 'Android Studio: ~/android-studio . To uncompress: tar xvzf FILE_NAME.tar.gz'
  echo 'And setup the ANDROID_HOME to correct one'
  echo 'https://developer.android.com/studio/index.html#downloads'
fi

if [ ! -f "$HOME"/.check-files/android-path ]; then
  echo '[~/.check-files/android-path]: Update to the correct path inside ~/.check-files/android-path.'
  echo 'If using studio, remember to first open it and download the CLI tools from Menu > Tools > SDK Manager'
fi

cat >> ~/.shellrc <<"EOF"
# This is the default location for Android Studio SDK location
# https://stackoverflow.com/a/61176718
# $HOME/android-sdk # For using CLI

# If using Android Studio instead. Remember to create a project and download CLI tools
# $HOME/Android/Sdk

ANDROID_PATH_FILE="$(cat ~/.check-files/android-path)"
export ANDROID_HOME="$ANDROID_PATH_FILE"

export ANDROID_SDK_ROOT="$ANDROID_HOME"
# it is important that takes priority over .../tools/bin
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/tools/bin"
export PATH="$PATH:$ANDROID_HOME/tools/bin/"
export PATH="$PATH:$ANDROID_HOME/platform-tools/"
export PATH="$PATH:$ANDROID_HOME/emulator/"
export PATH="$PATH:$HOME/android-studio/bin"
EOF

cat >> ~/.shell_aliases <<"EOF"
alias AndroidStudioExit='studio.sh & exit'
alias AndroidAVDManagerListAVD='avdmanager list avd'
alias EmulatorLaunch='emulator -avd'
EOF

if ! type adb > /dev/null 2>&1 ; then
  echo
  echo 'Download the platforms tools'
  echo 'Run: sdkmanager "platform-tools"'
  echo
fi

cat >> ~/.shell_aliases <<"EOF"
alias AdbOpenDeeplink='adb shell am start -d'
EOF

if [ "$PROVISION_OS" == "LINUX" ]; then
  cat >> /tmp/android-studio.desktop <<"EOF"
[Desktop Entry]
Version=1.0
Name=Android Studio
Comment=Android IDE
Exec=/home/igncp/android-studio/bin/studio.sh
StartupNotify=true
Terminal=false
Type=Application
EOF
  sudo mv /tmp/android-studio.desktop /usr/share/applications/
fi

# if running emulator on I3, move to floating mode

# android END

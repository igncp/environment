#!/usr/bin/env bash

set -euo pipefail

provision_setup_android() {
  cat >>~/.shell_aliases <<"EOF"
if type gradle >/dev/null 2>&1; then
  alias GradleInit='gradle init'
fi

if [ -f gradlew ]; then
  alias GradleProjects='./gradlew projects'
  alias GradleTasks='./gradlew tasks'
  alias GradleTasksAll='./gradlew tasks --all'
  alias GradleHelpTask='./gradlew -q help --task' # example: GradleHelpTask 'assemble'
  alias GradleDependencies='./gradlew -q buildEnvironment'
fi
EOF

  cat >>~/.shell_aliases <<"EOF"
alias AdbAPKs='adb shell pm list packages -f'
alias AdbClearData='adb shell pm clear' # pass package name
alias AdbDevMenu='adb shell input keyevent 82'
alias AdbForceStop='adb shell am force-stop' # pass package name
alias AdbInstall='adb install -r' # pass apk path
alias AdbListInstalled='adb shell cmd package list packages -3 -l'
alias AdbLogcat='adb shell logcat'
alias AdbOpenDeeplink='adb shell am start -d' # for query strings, encode with `encodeURIComponent`
alias AdbShutdown='adb shell reboot -p'
alias AdbStartActivity='adb shell am start -n' # pass package name and activity name, e.g. AdbStartActivity com.example.app/.MainActivity
alias AdbUninstall='adb uninstall' # pass package name

alias AndroidStudioExit='studio.sh & exit'
alias AndroidAVDManagerListAVD='avdmanager list avd'
alias AndroidSdkListInstalled='sdkmanager --list_installed' # pass --verbose to see more

alias AndroiDumpAPKInfo='aapt2 dump badging' # e.g. AndroiDebugAPK foo/app-debug.apk

alias EmulatorLaunch='emulator -avd'
alias EmulatorList='emulator -list-avds'
EOF

  if [ -d ~/Library/Android/sdk ]; then
    cat >>~/.shellrc <<"EOF"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/tools/bin:$PATH"

# 需要在最後
export PATH="$ANDROID_HOME/emulator:$PATH"
EOF
  fi

  if [ -d $HOME/Android/Sdk ]; then
    cat >>~/.shellrc <<"EOF"
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/tools:$PATH"
export PATH="$ANDROID_HOME/tools/bin:$PATH"
EOF
  fi

  if [ -d $HOME/android-studio ]; then
    cat >>~/.shellrc <<"EOF"
export PATH=$PATH:/home/igncp/android-studio/bin
EOF
  fi

  if [ ! -f $PROVISION_CONFIG/android ]; then
    return
  fi

  if [ "$IS_LINUX" == "1" ] && [ "$PROVISION_CONFIG"/gui ] && [ -d /usr/share/applications ]; then
    cat >/tmp/android-studio.desktop <<"EOF"
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

  if [[ "$(type -t add_desktop_common)" == "function" ]]; then
    cat >~/.scripts/open_chrome_inspect_devices.sh <<"EOF"
#!/usr/bin/env bash
echo 'chrome://inspect/#devices' | xclip -selection clipboard
i3-msg 'workspace e; exec google-chrome-stable --new-window'
EOF
    chmod +x ~/.scripts/open_chrome_inspect_devices.sh
    add_desktop_common \
      "$HOME/.scripts/open_chrome_inspect_devices.sh" 'inspect_devices' 'Inspect Devices'
  fi

  # If running emulator on I3, move to floating mode

  # This is the default location for Android Studio SDK location
  # https://stackoverflow.com/a/61176718
  # $HOME/android-sdk # For using CLI

  # If using Android Studio instead. Remember to create a project and download CLI tools
  # $HOME/Android/Sdk

  if [ -f "$PROVISION_CONFIG"/android-path ]; then
    ANDROID_PATH_FILE="$(cat $PROVISION_CONFIG/android-path)"
    cat >>~/.shellrc <<EOF
export ANDROID_HOME="$ANDROID_PATH_FILE"
EOF
  fi

  # This is the outdated config for Arch. When using NixOS, many of these are automatic

  # if [ ! -f "$HOME"/development/environment/project/.config/android-path ]; then
  #   echo '[~/development/environment/project/.config/android-path]: Update to the correct path inside ~/development/environment/project/.config/android-path'
  #   echo 'If using studio, remember to first open it and download the CLI tools from Menu > Tools > SDK Manager'
  #   echo 'Example for android-path when using studio: $HOME/Android/Sdk'
  # fi
}

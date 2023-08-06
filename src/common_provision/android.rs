use std::path::Path;

use crate::base::{config::Config, Context};

pub fn setup_android(context: &mut Context) {
    if !Config::has_config_file(&context.system, ".config/android") {
        return;
    }

    if !context.system.get_has_binary("adb") {
        println!(
            r###"
Download the platforms tools
Run: sdkmanager "platform-tools"
"###
        );
    }

    context.home_append(
        ".shell_aliases",
        &format!(
            r###"
alias AdbOpenDeeplink='adb shell am start -d' # for query strings, encode with `encodeURIComponent`
alias AdbLogcat='adb shell logcat'
alias AdbAPKs='adb shell pm list packages -f'
alias AdbShutdown='adb shell reboot -p'
alias AdbForceStop='adb shell am force-stop' # pass package name

alias AndroidStudioExit='studio.sh & exit'
alias AndroidAVDManagerListAVD='avdmanager list avd'
alias AndroidSdkListInstalled='sdkmanager --list_installed' # pass --verbose to see more
alias EmulatorLaunch='emulator -avd'

alias GradleProjects='./gradlew projects'
alias GradleTasks='./gradlew tasks'
alias GradleTasksAll='./gradlew tasks --all'
alias GradleHelpTask='./gradlew -q help --task' # example: GradleHelpTask 'assemble'
alias GradleDependencies='./gradlew -q buildEnvironment'
    "###,
        ),
    );

    if Path::new(&context.system.get_home_path("Android/Sdk")).exists() {
        context.home_append(
            ".shellrc",
            r###"
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/tools:$PATH"
export PATH="$ANDROID_HOME/tools/bin:$PATH"
"###,
        );
    }
}

// This is the outdated config for Arch. When using NixOS, many of these are automatic

// if [ ! -d ~/android-sdk ] && [ ! -d ~/android-studio ] && [ ! -d ~/Library/Android/sdk ]; then
//   echo 'Download android CLI tools (or Studio if necessary, not both)'
//   echo 'Android CLI: structure should be ~/android-sdk/cmdline-tools/tools/bin/sdkmanager'
//   echo 'Android Studio: ~/android-studio . To uncompress: tar xvzf FILE_NAME.tar.gz'
//   echo '  In Arch Linux, when one user: yay -S --noconfirm android-sdk ; sudo chown -R $USER:$USER /opt/android-sdk'
//   echo 'And setup the ANDROID_HOME to correct one'
//   echo 'https://developer.android.com/studio/index.html#downloads'
// fi

// if [ ! -f "$HOME"/development/environment/project/.config/android-path ]; then
//   echo '[~/development/environment/project/.config/android-path]: Update to the correct path inside ~/development/environment/project/.config/android-path'
//   echo 'If using studio, remember to first open it and download the CLI tools from Menu > Tools > SDK Manager'
//   echo 'Example for android-path when using studio: $HOME/Android/Sdk'
// fi

// If running emulator on I3, move to floating mode

// cat >> ~/.shellrc <<"EOF"
// # This is the default location for Android Studio SDK location
// # https://stackoverflow.com/a/61176718
// # $HOME/android-sdk # For using CLI

// # If using Android Studio instead. Remember to create a project and download CLI tools
// # $HOME/Android/Sdk

// ANDROID_PATH_FILE="$(cat ~/development/environment/project/.config/android-path)"
// export ANDROID_HOME="$ANDROID_PATH_FILE"

// if [ "$PROVISION_OS" == "LINUX" ]; then
//   cat >> /tmp/android-studio.desktop <<"EOF"
// [Desktop Entry]
// Version=1.0
// Name=Android Studio
// Comment=Android IDE
// Exec=/home/igncp/android-studio/bin/studio.sh
// StartupNotify=true
// Terminal=false
// Type=Application
// EOF
//   sudo mv /tmp/android-studio.desktop /usr/share/applications/
// fi

// if [[ $(type -t add_desktop_common) == function ]]; then
//   cat > ~/.scripts/open_chrome_inspect_devices.sh <<"EOF"
// #!/usr/bin/env bash
// echo 'chrome://inspect/#devices' | xclip -selection clipboard
// i3-msg 'workspace e; exec google-chrome-stable --new-window'
// EOF
//   chmod +x ~/.scripts/open_chrome_inspect_devices.sh
//   add_desktop_common \
//     "$HOME/.scripts/open_chrome_inspect_devices.sh" 'inspect_devices' 'Inspect Devices'
// fi

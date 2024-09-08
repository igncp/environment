#!/usr/bin/env bash

set -e

. src/os/mac/brew.sh

provision_setup_os_mac() {
  # Rime - Squirrel
  #   I can't remember the location, but it may be from:
  #     https://github.com/rime/squirrel/releases
  #     https://github.com/rime/squirrel/issues/471#issuecomment-748751617
  #   Use `~/Library/Rime/default.custom.yaml``
  #   The `patch` in the top level, above `schemas`, is necessary

  mkdir -p ~/Library/KeyBindings

  cat >>~/.shellrc <<"EOF"
umask 027
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
EOF

  echo 'set backspace=indent,eol,start' >>~/.vimrc

  cat >~/Library/KeyBindings/DefaultKeyBinding.dict <<EOF
{
  /* Map # to § key*/
  "§" = ("insertText:", "#");
}
EOF

  cat >>~/.shell_aliases <<"EOF"
alias MacDisks='diskutil list'
alias MacFeatures='system_profiler > /tmp/features.txt && echo "/tmp/features.txt written" && less /tmp/features.txt'
alias BrewListPackages='brew list'
alias MacServices=$'sudo launchctl list | awk \'{ print $3; }\' | sort | less'

MacListServices() { launchctl  list | ag -v '^-' | awk '{ print $3; }' | ag -v ^Label$ | sort | less; }
alias MacListAppsAppStore='mdfind kMDItemAppStoreHasReceipt=1'
alias MacEjectAll="osascript -e 'tell application "'"Finder"'" to eject (every disk whose ejectable is true)'"

# 編輯此文件: `/etc/pf.conf`
# 例如: `pass in proto tcp from any to any port 3000`
alias MacRestartFirewallConfig='sudo pfctl -f /etc/pf.conf'

alias SimulatorErase='xcrun simctl shutdown all && xcrun simctl erase all'
MacListServices() { launchctl  list | ag -v '^-' | awk '{ print $3; }' | ag -v ^Label$ | sort | less; }
EOF

  disable_mac_hotkey() {
    NUM=$1
    CURRENT_VALUE="$(plutil -extract AppleSymbolicHotKeys.$NUM.enabled raw -o - ~/Library/Preferences/com.apple.symbolichotkeys.plist)"
    if [ $CURRENT_VALUE = "true" ]; then
      echo "更新鍵盤快速鍵: $NUM"
      plutil -replace AppleSymbolicHotKeys.$NUM.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist
      defaults read com.apple.symbolichotkeys.plist >/dev/null
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    fi
  }

  # Mission Control: Option + up
  disable_mac_hotkey 32
  # Mission Control: left and right
  disable_mac_hotkey 79
  disable_mac_hotkey 80
  disable_mac_hotkey 81
  disable_mac_hotkey 82

  if [ ! -f ~/.check-files/init-apps ]; then
    # 降低透明度
    defaults write com.apple.universalaccess reduceTransparency -bool true || true

    # Safari debug
    defaults write com.apple.Safari IncludeInternalDebugMenu -bool true &&
      defaults write com.apple.Safari IncludeDevelopMenu -bool true &&
      defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true &&
      defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true &&
      defaults write -g WebKitDeveloperExtras -bool true || true

    # 斷開螢幕分享用戶端後保持螢幕常亮
    sudo defaults write /Library/Preferences/com.apple.RemoteManagement RestoreMachineState -bool NO

    # Xcode command-line tools
    xcode-select --install || true

    # 停用空間的自動排列
    defaults write com.apple.dock mru-spaces -bool false && killall Dock
    # 自動隱藏底座
    defaults write com.apple.dock autohide -bool true && killall Dock
    # 禁用通知上的圖示彈跳
    defaults write com.apple.dock no-bouncing -bool false && killall Dock
    # 顯示隱藏文件
    defaults write com.apple.finder AppleShowAllFiles true
    # 顯示隱藏目錄
    chflags nohidden ~/Library
    # 隱藏桌面圖標
    defaults write com.apple.finder CreateDesktop -bool false && killall Finder
    # 在底部顯示路徑欄
    defaults write com.apple.finder ShowPathbar -bool true

    touch ~/.check-files/init-apps
  fi

  provision_setup_os_mac_brew
}

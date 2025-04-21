#!/usr/bin/env bash

set -e

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
EOF

  cat >>~/.shell_aliases <<"EOF"
MacListServices() { launchctl  list | ag -v '^-' | awk '{ print $3; }' | ag -v ^Label$ | sort | less; }
alias MacPowerManagementClearRepeat='sudo pmset repeat cancel'
alias MacPowerManagementList='sudo pmset -g sched'
alias MacPowerManagementListAll='sudo pmset -g everything'
# 每個平日凌晨四點停機
# sudo pmset repeat shutdown MTWRF 04:00:00
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
alias MacEjectAll="osascript -e 'tell application "'"Finder"'" to eject (every disk whose ejectable is true)'"
alias MacFeatures='system_profiler > /tmp/features.txt && echo "/tmp/features.txt written" && less /tmp/features.txt'
alias MacListAppsAppStore='mdfind kMDItemAppStoreHasReceipt=1'
alias MacDefaultDomains=$'defaults domains | tr \', \' \'\n\' | ag . | sort | less'
alias MacServices=$'sudo launchctl list | awk \'{ print $3; }\' | sort | less'
alias MacAddUserToAdmin="sudo dscl . -append /Groups/admin GroupMembership $USER"
alias MacListUsers='dscl . list /Users UniqueID | sort -n -k2'
alias MacListIdentities='security find-identity'

alias MacXCodePrintUsed='xcode-select --print-path'
MacXCodeUpdateCommandLineTools() {
  sudo rm -rf /Library/Developer/CommandLineTools
  sudo xcode-select --install
}

MacInstallPkg() { sudo installer -store -pkg "$1" -target /; }
MacListServices() { launchctl  list | ag -v '^-' | awk '{ print $3; }' | ag -v ^Label$ | sort | less; }

# 編輯此文件: `/etc/pf.conf`
# 例如: `pass in proto tcp from any to any port 3000`
alias MacRestartFirewallConfig='sudo pfctl -f /etc/pf.conf'

# When there is error about signature in custom scripts
alias MacForceSignature='codesign --force --deep --sign -' # For example: `MacForceSignature $HOME/.local/bin/clipboard_ssh`

alias SimulatorErase='xcrun simctl shutdown all && xcrun simctl erase all'
EOF

  disable_mac_hotkey() {
    NUM=$1
    CURRENT_VALUE="$(plutil -extract AppleSymbolicHotKeys.$NUM.enabled raw -o - ~/Library/Preferences/com.apple.symbolichotkeys.plist || true)"
    if [ "$CURRENT_VALUE" = "true" ]; then
      echo "更新鍵盤快速鍵: $NUM"
      plutil -replace AppleSymbolicHotKeys.$NUM.enabled -bool NO ~/Library/Preferences/com.apple.symbolichotkeys.plist || true
      defaults read com.apple.symbolichotkeys.plist >/dev/null || true
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u || true
    fi
  }

  if [ ! -f "$PROVISION_CONFIG"/minimal ]; then
    # Mission Control: Option + up
    disable_mac_hotkey 32
    # Mission Control: left and right
    disable_mac_hotkey 79
    disable_mac_hotkey 80
    disable_mac_hotkey 81
    disable_mac_hotkey 82
  fi

  if [ ! -f ~/.check-files/init-apps ] && [ ! -f "$PROVISION_CONFIG"/minimal ]; then
    # 降低透明度
    defaults write com.apple.universalaccess reduceTransparency -bool true || true

    # Safari debug
    (defaults write com.apple.Safari IncludeInternalDebugMenu -bool true &&
      defaults write com.apple.Safari IncludeDevelopMenu -bool true &&
      defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true &&
      defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true &&
      defaults write -g WebKitDeveloperExtras -bool true) || true

    # 斷開螢幕分享用戶端後保持螢幕常亮
    sudo defaults write /Library/Preferences/com.apple.RemoteManagement RestoreMachineState -bool NO || true

    # Xcode command-line tools
    xcode-select --install || true

    # 停用空間的自動排列
    defaults write com.apple.dock mru-spaces -bool false && killall Dock || true
    # 自動隱藏底座
    defaults write com.apple.dock autohide -bool true && killall Dock || true
    # 禁用通知上的圖示彈跳
    defaults write com.apple.dock no-bouncing -bool false && killall Dock || true
    # 顯示隱藏文件
    defaults write com.apple.finder AppleShowAllFiles true || true
    # 顯示隱藏目錄
    chflags nohidden ~/Library || true
    # 隱藏桌面圖標
    defaults write com.apple.finder CreateDesktop -bool false && killall Finder || true
    # 在底部顯示路徑欄
    defaults write com.apple.finder ShowPathbar -bool true || true
    # 用 Ctr + Cmd + 滑鼠拖曳個視窗
    defaults write -g NSWindowShouldDragOnGesture -bool true
    # 喺電池入面顯示百分比圖示
    defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true
    # 打開新檔案嗰陣唔好打開之前嘅預覽檔案（例如 PDF ）
    defaults write com.apple.Preview ApplePersistenceIgnoreState YES
    # 自動隱藏選單列
    defaults write NSGlobalDomain _HIHideMenuBar -bool true

    touch ~/.check-files/init-apps
  fi

  if [ ! -f ~/.aerospace.toml ] && [ -d /Applications/Aerospace.app ]; then
    cp /Applications/AeroSpace.app/Contents/Resources/default-config.toml \
      ~/.aerospace.toml
  fi

  # 轉移 Nix 用戶嚟解決問題
  # curl --proto '=https' --tlsv1.2 -sSf -L \
  #   https://github.com/NixOS/nix/raw/master/scripts/sequoia-nixbld-user-migration.sh | bash -
}

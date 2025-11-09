#!/bin/bash

set -euo pipefail

IDE_POSSIBLE_CONFIG_FILES=(
  "$HOME/.config/Code/User/settings.json"
  "$HOME/.config/Cursor/User/settings.json"
  "$HOME/Library/Application Support/Code/User/settings.json"
  "$HOME/Library/Application Support/Cursor/User/settings.json"
)

if [ -f "$PROVISION_CONFIG"/gui-vscode ]; then
  rm -rf /tmp/current-vscode-extensions
fi

if [ -f "$PROVISION_CONFIG"/gui-cursor ]; then
  rm -rf /tmp/current-cursor-extensions
fi

add_vscode_extension() {
  if [ -f "$PROVISION_CONFIG"/gui-vscode ] || [ -f "$PROVISION_CONFIG"/gui-cursor ]; then
    if [ -f "$PROVISION_CONFIG"/gui-vscode ] && [ "${2:-}" != "cursor" ]; then
      if ! type code >/dev/null; then
        echo "VSCode 未安裝，正在跳過擴充安裝: $1"
        return
      fi

      if [ ! -f /tmp/current-vscode-extensions ]; then
        code --list-extensions | sort -V >/tmp/current-vscode-extensions
      fi

      if [ -z "$(cat /tmp/current-vscode-extensions | grep "$1" || true)" ]; then
        code --install-extension "$1"
      fi
    fi

    if [ -f "$PROVISION_CONFIG"/gui-cursor ] && [ "${2:-}" != "vscode" ]; then
      if ! type cursor >/dev/null 2>&1; then
        if [ $IS_NIXOS != "1" ]; then
          echo "Cursor 未安裝，正在跳過擴充安裝: https://cursor.com/home"
        fi
        return
      fi

      if [ ! -f /tmp/current-cursor-extensions ]; then
        cursor --list-extensions | sort -V >/tmp/current-cursor-extensions
      fi

      if [ -z "$(cat /tmp/current-cursor-extensions | grep "$1" || true)" ]; then
        cursor --install-extension "$1"
      fi
    fi
  fi
}

provision_setup_vscode() {
  if [ ! -f "$PROVISION_CONFIG"/gui-vscode ] && [ ! -f "$PROVISION_CONFIG"/gui-cursor ]; then
    return
  fi

  for POSSIBLE_CONFIG_FILE in "${IDE_POSSIBLE_CONFIG_FILES[@]}"; do
    if [ -d "$(dirname "$POSSIBLE_CONFIG_FILE")" ]; then
      cat ~/development/environment/src/config-files/vscode/settings.json |
        jq -S >"$POSSIBLE_CONFIG_FILE"

      jq --argjson new_data "$(cat ~/development/environment/src/config-files/vscode/vim-normal-mappings.json)" \
        '."vim.normalModeKeyBindingsNonRecursive" = $new_data' \
        "$POSSIBLE_CONFIG_FILE" | sponge "$POSSIBLE_CONFIG_FILE"

      jq --argjson new_data "$(cat ~/development/environment/src/config-files/vscode/vim-visual-mappings.json)" \
        '."vim.visualModeKeyBindingsNonRecursive" = $new_data' \
        "$POSSIBLE_CONFIG_FILE" | sponge "$POSSIBLE_CONFIG_FILE"

      MAIN_PATH="$(dirname "$POSSIBLE_CONFIG_FILE")"
      cp src/config-files/vscode/common.code-snippets \
        "$MAIN_PATH"/snippets
    fi
  done

  add_vscode_extension "waderyan.gitblame"
  add_vscode_extension "vscodevim.vim"
  add_vscode_extension "jkillian.custom-local-formatters"
  add_vscode_extension "cocopon.iceberg-theme"

  # add_vscode_extension "ms-vscode-remote.remote-ssh" vscode
  # add_vscode_extension "ms-vscode-remote.remote-ssh-edit" vscode

  KEYBINDINGS_PATHS=(
    "$HOME/.config/Cursor/User/keybindings.json"
    "$HOME/.config/Code/User/keybindings.json"
    "$HOME/Library/Application Support/Cursor/User/keybindings.json"
    "$HOME/Library/Application Support/Code/User/keybindings.json"
  )

  for KEYBINDINGS_PATH in "${KEYBINDINGS_PATHS[@]}"; do
    if [ -d "$(dirname "$KEYBINDINGS_PATH")" ]; then
      cp $HOME/development/environment/src/config-files/vscode/key-mappings.json "$KEYBINDINGS_PATH"
    fi
  done

  if [ ! -f "$PROVISION_CONFIG"/no-copilot ]; then
    add_vscode_extension "github.copilot" vscode
  fi

  if [ "$IS_NIXOS" = "1" ] && [ -f "$PROVISION_CONFIG"/gui-cursor ]; then
    add_desktop_common \
      "$HOME/development/environment/src/scripts/misc/cursor_appimage.sh" 'cursor-appimage' 'Cursor AppImage'
  fi

  VSIX_FILE="$HOME/development/environment/src/vscode-extension/igncp-vscode-extension-0.0.1.vsix"
  if [ ! -f "$VSIX_FILE" ]; then
    cd ~/development/environment/src/vscode-extension
    bun i && bun run package
    type code >/dev/null 2>&1 && code --install-extension "$VSIX_FILE"
    type cursor >/dev/null 2>&1 && cursor --install-extension "$VSIX_FILE"
  fi

  cat >>~/.shellrc <<"EOF"
if [ -d /Applications/Cursor.app/Contents/Resources/app/bin ]; then
  export PATH="/Applications/Cursor.app/Contents/Resources/app/bin/:$PATH"
fi
EOF
}

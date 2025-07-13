#!/bin/bash

set -euo pipefail

if [ -f "$PROVISION_CONFIG"/gui-vscode ]; then
  rm -rf /tmp/current-vscode-extensions
fi

add_vscode_extension() {
  if [ -f "$PROVISION_CONFIG"/gui-vscode ]; then
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
}

set_vscode_setting_if_missing() {
  if [ ! -f "$PROVISION_CONFIG"/gui-vscode ]; then
    return
  fi

  local CONFIG_FILE=''
  local POSSIBLE_CONFIG_FILES=(
    "$HOME/.config/Code/User/settings.json"
    "$HOME/Library/Application Support/Code/User/settings.json"
  )

  for POSSIBLE_CONFIG_FILES in "${POSSIBLE_CONFIG_FILES[@]}"; do
    if [ -f "$POSSIBLE_CONFIG_FILES" ]; then
      CONFIG_FILE="$POSSIBLE_CONFIG_FILES"
      break
    fi
  done

  if [ -n "$CONFIG_FILE" ]; then
    if [ -z "$(cat "$CONFIG_FILE" | grep "$1" || true)" ]; then
      local CONTENT=$(cat "$CONFIG_FILE")
      if [ -z "$CONTENT" ]; then
        echo "{}" >"$CONFIG_FILE"
      fi
      cat "$CONFIG_FILE" | jq '. += { "'$1'": '$2' }' | jq -S . | sponge "$CONFIG_FILE"
    fi
  fi
}

provision_setup_vscode() {
  if [ ! -f "$PROVISION_CONFIG"/gui-vscode ]; then
    return
  fi

  set_vscode_setting_if_missing "css.validate" false
  set_vscode_setting_if_missing "editor.accessibilitySupport" '"off"'
  set_vscode_setting_if_missing "editor.copyWithSyntaxHighlighting" false
  set_vscode_setting_if_missing "editor.guides.indentation" false
  set_vscode_setting_if_missing "editor.renderLineHighlight" '"none"'
  set_vscode_setting_if_missing "extensions.ignoreRecommendations" true
  set_vscode_setting_if_missing "less.validate" false
  set_vscode_setting_if_missing "php.validate.enable" false
  set_vscode_setting_if_missing "scss.validate" false
  set_vscode_setting_if_missing "telemetry.telemetryLevel" '"off"'
  set_vscode_setting_if_missing "workbench.enableExperiments" false
  set_vscode_setting_if_missing "workbench.statusBar.visible" true

  add_vscode_extension "waderyan.gitblame"
  add_vscode_extension "ms-vscode-remote.remote-ssh"
  add_vscode_extension "ms-vscode-remote.remote-ssh-edit"

  if [ -f "$PROVISION_CONFIG"/copilot ]; then
    add_vscode_extension "github.copilot"
  fi

  #    "breadcrumbs.enabled": false,
  #     "editor.formatOnSave": true,
  #     "editor.minimap.enabled": false,
  #     "scm.diffDecorations": "overview",
  #     "window.menuBarVisibility": "toggle",
  #     "window.zoomLevel": 1,
  #     "workbench.activityBar.visible": false,
  #     "editor.cursorBlinking": "solid",
  #     "workbench.colorCustomizations": {
  #         "editorCursor.foreground": "#f1345d",
  #         "editorCursor.background": "#000000",
  #         "statusBar.background": "#303030",
  #         "statusBar.noFolderBackground": "#222225",
  #         "statusBar.debuggingBackground": "#511f1f",
  #     },
  #     "dart.closingLabels": false,
  #     "javascript.validate.enable": false,
  #     "eslint.validate": [
  #         "typescript",
  #         "typescriptreact"
  #     ],
  #     "editor.suggestSelection": "first",

  # [
  #     {
  #         "key": "ctrl+d",
  #         "command": "workbench.action.closeActiveEditor"
  #     },
  #     {
  #         "key": "ctrl+shift+y",
  #         "command": "workbench.action.terminal.toggleTerminal",
  #         "when": "!terminalFocus"
  #     },
  #     {
  #         "key": "ctrl+1",
  #         "command": "workbench.action.openEditorAtIndex1"
  #     },
  #     {
  #         "key": "ctrl+2",
  #         "command": "workbench.action.openEditorAtIndex2"
  #     },
  #     {
  #         "key": "ctrl+3",
  #         "command": "workbench.action.openEditorAtIndex3"
  #     },
  #     {
  #         "key": "ctrl+4",
  #         "command": "workbench.action.openEditorAtIndex4"
  #     },
  #     {
  #         "key": "ctrl+5",
  #         "command": "workbench.action.openEditorAtIndex5"
  #     },
  #     {
  #         "key": "ctrl+6",
  #         "command": "workbench.action.openEditorAtIndex6"
  #     },
  #     {
  #         "key": "ctrl+z",
  #         "command": "workbench.action.terminal.focus"
  #     },
  #     {
  #         "key": "ctrl+s",
  #         "command": "-workbench.action.files.save"
  #     },
  #     {
  #         "key": "ctrl+e",
  #         "command": "-workbench.action.quickOpen"
  #     },
  # ]
}

#!/bin/bash

set -e

set_vscode_setting_if_missing() {
  if [ ! -f "$PROVISION_CONFIG"/gui-vscode ]; then
    return
  fi

  local CONFIG_FILE=''

  if [ -f ~/.config/Code/User/settings.json ]; then
    CONFIG_FILE="$HOME/.config/Code/User/settings.json"
  fi

  if [ -n "$CONFIG_FILE" ]; then
    if [ -z "$(cat "$CONFIG_FILE" | grep "$1" || true)" ]; then
      cat "$CONFIG_FILE" | jq '. += { "'$1'": '$2' }' | sponge "$CONFIG_FILE"
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
  set_vscode_setting_if_missing "extensions.ignoreRecommendations" true
  set_vscode_setting_if_missing "less.validate" false
  set_vscode_setting_if_missing "php.validate.enable" false
  set_vscode_setting_if_missing "scss.validate" false
  set_vscode_setting_if_missing "telemetry.telemetryLevel" '"off"'
  set_vscode_setting_if_missing "workbench.enableExperiments" false
}

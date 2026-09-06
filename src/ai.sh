#!/usr/bin/env bash

set -euo pipefail

provision_setup_ai() {
  cat >>~/.shellrc <<"EOF"
if type ollama >/dev/null 2>&1; then
  alias OllamaRun8b="ollama run llama3:8b"
  alias OllamaRunPhi3="ollama run phi3" # 適合慢速機器
fi
if type chroma >/dev/null 2>&1; then
  ChromaStart() {
    local path="${1:-./my_db_path}"
    local port="${2:-8000}"
    chroma run --path "$path" --port "$port"
  }
fi
EOF

  if [ ! -f "$PROVISION_CONFIG"/job ]; then
    mkdir -p "$HOME/.config/copilot-restricted/agents"
    cp -r $HOME/development/environment/src/config-files/ai-prompts/* "$HOME/.config/copilot-restricted/agents/"

    mkdir -p "$HOME/.config/opencode/commands"
    rm -rf "$HOME/.config/opencode/commands"/*
    for PROMPT_FILE in "$HOME"/development/environment/src/config-files/ai-prompts/*; do
      PROMPT_DESTINATION="$HOME/.config/opencode/commands/$(basename "$PROMPT_FILE")"
      cp "$PROMPT_FILE" "$PROMPT_DESTINATION"
    done

    SETTINGS_FILE="$HOME/.config/copilot-restricted/settings.json"
    if [ ! -f "$SETTINGS_FILE" ]; then
      printf '{}\n' >"$SETTINGS_FILE"
    fi
    SETTINGS_FILE_TMP=$(mktemp)
    jq -S \
      '.model = "gpt-5.6-luna" | .stayInAutopilot = false' \
      "$SETTINGS_FILE" >"$SETTINGS_FILE_TMP"
    if ! cmp -s "$SETTINGS_FILE_TMP" "$SETTINGS_FILE"; then
      mv "$SETTINGS_FILE_TMP" "$SETTINGS_FILE"
    else
      rm "$SETTINGS_FILE_TMP"
    fi

    # https://github.com/settings/billing/ai_usage
    cat >>~/.shellrc <<"EOF"
export COPILOT_HOME="$HOME/.config/copilot-restricted"

# 強制將超過 2KB 嘅輸出／檔案讀取截短成預覽
# 大幅減少大量檔案或 shell 回傳內容消耗嘅 token。
export COPILOT_LARGE_OUTPUT_THRESHOLD_BYTES=2048

# 強制 Copilot CLI 工具查詢按需載入，而唔係一次過載入所有 schema。
export COPILOT_LAZY_TOOL_SEARCH=true
EOF
  fi
}

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
}

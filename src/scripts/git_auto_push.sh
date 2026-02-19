#!/usr/bin/env bash

set -e

(. "$HOME/.nix-profile/etc/profile.d/nix.sh" 2>&1 &>/dev/null) || true
export PATH="$PATH:/run/current-system/sw/bin/"

export LC_ALL=C
export LANG=C

CONFIG_FILE="$HOME/.config/igncp_git_auto_push.txt"
INTERVAL_MINUTES=10
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
PAUSED_MARKER="#PAUSED#"

MACOS_PLIST_NAME="com.igncp.git-auto-push"
MACOS_LAUNCHAGENTS_DIR="$HOME/Library/LaunchAgents"
MACOS_LOGS_DIR="$HOME/Library/Logs"

LINUX_SERVICE_NAME="igncp-git-auto-push"
LINUX_SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

load_ssh_agent() {
  local os_type=$(detect_os)

  if [[ "$os_type" == "macos" ]]; then
    export SSH_AUTH_SOCK="$(find /tmp/com.apple.launchd.*/Listeners -type s 2>/dev/null | head -n1)"
  else
    SSH_ENV="$HOME/.ssh-agent-environment"

    if [ -f "$SSH_ENV" ]; then
      . "$SSH_ENV" >/dev/null
      if ! ps -ef | grep "$SSH_AGENT_PID" | grep 'ssh-agent$' >/dev/null 2>&1; then
        echo "警告：SSH 代理未運行。請手動啟動 ssh-agent。"
      fi
    else
      echo -e "警告：SSH 代理環境文件未找到。請手動啟動 ssh-agent。"
      exit 1
    fi
  fi
}

detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

send_notification() {
  local title="$1"
  local message="$2"
  local os_type=$(detect_os)

  if [[ "$os_type" == "macos" ]]; then
    osascript -e "display notification \"$message\" with title \"$title\""
  elif [[ "$os_type" == "linux" ]]; then
    if command -v notify-send &>/dev/null; then
      notify-send "$title" "$message"
    fi
  fi
}

install_macos() {
  local plist_path="$MACOS_LAUNCHAGENTS_DIR/${MACOS_PLIST_NAME}.plist"

  echo "正在安裝 macOS 嘅 launchd 服務..."

  mkdir -p "$MACOS_LAUNCHAGENTS_DIR"

  cat >"$plist_path" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${MACOS_PLIST_NAME}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${SCRIPT_PATH}</string>
        <string>run</string>
    </array>
    <key>StartInterval</key>
    <integer>$((INTERVAL_MINUTES * 60))</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$MACOS_LOGS_DIR/${MACOS_PLIST_NAME}.log</string>
    <key>StandardErrorPath</key>
    <string>$MACOS_LOGS_DIR/${MACOS_PLIST_NAME}.error.log</string>
</dict>
</plist>
EOF

  launchctl unload "$plist_path" 2>/dev/null || true
  launchctl load "$plist_path"

  echo "✓ 已安裝並加載 launchd 服務"
  echo "  配置：$plist_path"
  echo "  日誌：$MACOS_LOGS_DIR/${MACOS_PLIST_NAME}.log"
}

install_linux() {
  local service_path="$LINUX_SYSTEMD_USER_DIR/${LINUX_SERVICE_NAME}.service"
  local timer_path="$LINUX_SYSTEMD_USER_DIR/${LINUX_SERVICE_NAME}.timer"

  echo "正在安裝 Linux 嘅 systemd 服務..."

  mkdir -p "$LINUX_SYSTEMD_USER_DIR"
  NIX_PREFIX=""

  if [ -e /etc/NIXOS ]; then
    NIX_PREFIX="/run/current-system/sw/bin/bash "
  fi

  cat >"$service_path" <<EOF
[Unit]
Description=Auto push git repositories
After=network.target

[Service]
Type=oneshot
ExecStart=${NIX_PREFIX}${SCRIPT_PATH} run

[Install]
WantedBy=default.target
EOF

  cat >"$timer_path" <<EOF
[Unit]
Description=Run git auto push every ${INTERVAL_MINUTES} minutes

[Timer]
OnBootSec=${INTERVAL_MINUTES}min
OnUnitActiveSec=${INTERVAL_MINUTES}min
Persistent=true

[Install]
WantedBy=timers.target
EOF

  systemctl --user daemon-reload
  systemctl --user enable "${LINUX_SERVICE_NAME}.timer"
  systemctl --user start "${LINUX_SERVICE_NAME}.timer"

  echo "✓ 已安裝並啟動 systemd 服務"
  echo "  服務：$service_path"
  echo "  計時器：$timer_path"
  echo ""
  echo "查看狀態：systemctl --user status ${LINUX_SERVICE_NAME}.timer"
  echo "查看日誌：journalctl --user -u ${LINUX_SERVICE_NAME}.service"
}

uninstall_service() {
  local os_type=$(detect_os)

  if [[ "$os_type" == "macos" ]]; then
    local plist_path="$MACOS_LAUNCHAGENTS_DIR/${MACOS_PLIST_NAME}.plist"

    if [[ -f "$plist_path" ]]; then
      launchctl unload "$plist_path"
      rm "$plist_path"
      echo "✓ 已卸載 launchd 服務"
    else
      echo "未找到 launchd 服務"
    fi
  elif [[ "$os_type" == "linux" ]]; then
    systemctl --user stop "${LINUX_SERVICE_NAME}.timer" 2>/dev/null || true
    systemctl --user disable "${LINUX_SERVICE_NAME}.timer" 2>/dev/null || true
    rm -f "$LINUX_SYSTEMD_USER_DIR/${LINUX_SERVICE_NAME}.service"
    rm -f "$LINUX_SYSTEMD_USER_DIR/${LINUX_SERVICE_NAME}.timer"
    systemctl --user daemon-reload
    echo "✓ 已卸載 systemd 服務"
  else
    echo "未知嘅操作系統類型"
    exit 1
  fi
}

install_service() {
  local os_type=$(detect_os)

  if [[ "$os_type" == "macos" ]]; then
    install_macos
  elif [[ "$os_type" == "linux" ]]; then
    install_linux
  else
    echo "不支持嘅操作系統：$os_type"
    exit 1
  fi

  echo ""
  echo "將倉庫路徑加到：$CONFIG_FILE"
  echo "每行一個路徑。"
}

add_current_dir() {
  local current_dir="$(pwd)"

  if [[ ! -d "$current_dir/.git" ]]; then
    echo "錯誤：當前目錄唔係 git 倉庫"
    exit 1
  fi

  mkdir -p "$(dirname "$CONFIG_FILE")"
  touch "$CONFIG_FILE"

  if grep -Fxq "$current_dir" "$CONFIG_FILE"; then
    echo "路徑已經存在於配置中：$current_dir"
    exit 0
  fi

  echo "$current_dir" >>"$CONFIG_FILE"
  echo "✓ 已加到配置：$current_dir"
  echo ""
  echo "配置文件：$CONFIG_FILE"
}

pause_repo() {
  local target_dir="${1:-$(pwd)}"

  # 展開波浪號
  target_dir="${target_dir/#\~/$HOME}"

  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "未找到配置文件：$CONFIG_FILE"
    exit 1
  fi

  # 檢查倉庫係咪存在於配置中
  local found=false
  local temp_file=$(mktemp)

  while IFS= read -r line; do
    local expanded_line="${line/#\~/$HOME}"
    if [[ "$expanded_line" == "$target_dir" ]]; then
      found=true
      echo "${PAUSED_MARKER}$line" >>"$temp_file"
    elif [[ "$line" == "${PAUSED_MARKER}"* ]] && [[ "${line/#${PAUSED_MARKER}/}" == "$target_dir" || "${line/#${PAUSED_MARKER}/}" == "$target_dir" ]]; then
      # 已經暫停
      echo "$line" >>"$temp_file"
      echo "倉庫已經係暫停狀態：$target_dir"
      rm "$temp_file"
      exit 0
    else
      echo "$line" >>"$temp_file"
    fi
  done <"$CONFIG_FILE"

  if [[ "$found" == "true" ]]; then
    mv "$temp_file" "$CONFIG_FILE"
    echo "✓ 已暫停自動推送：$target_dir"
  else
    rm "$temp_file"
    echo "錯誤：倉庫唔存在於配置中：$target_dir"
    exit 1
  fi
}

resume_repo() {
  local target_dir="${1:-$(pwd)}"

  # 展開波浪號
  target_dir="${target_dir/#\~/$HOME}"

  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "未找到配置文件：$CONFIG_FILE"
    exit 1
  fi

  # 檢查倉庫係咪存在於配置中
  local found=false
  local temp_file=$(mktemp)

  while IFS= read -r line; do
    if [[ "$line" == "${PAUSED_MARKER}"* ]]; then
      local repo_path="${line/#${PAUSED_MARKER}/}"
      local expanded_repo="${repo_path/#\~/$HOME}"

      if [[ "$expanded_repo" == "$target_dir" ]]; then
        found=true
        echo "$repo_path" >>"$temp_file"
      else
        echo "$line" >>"$temp_file"
      fi
    else
      local expanded_line="${line/#\~/$HOME}"
      if [[ "$expanded_line" == "$target_dir" ]]; then
        # 已經係活動狀態
        echo "$line" >>"$temp_file"
        echo "倉庫已經係活動狀態：$target_dir"
        rm "$temp_file"
        exit 0
      else
        echo "$line" >>"$temp_file"
      fi
    fi
  done <"$CONFIG_FILE"

  if [[ "$found" == "true" ]]; then
    mv "$temp_file" "$CONFIG_FILE"
    echo "✓ 已恢復自動推送：$target_dir"
  else
    rm "$temp_file"
    echo "錯誤：倉庫唔存在於配置中或者未被暫停：$target_dir"
    exit 1
  fi
}

list_repos() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "未找到配置文件：$CONFIG_FILE"
    exit 0
  fi

  if [[ ! -s "$CONFIG_FILE" ]]; then
    echo "配置文件係空嘅：$CONFIG_FILE"
    exit 0
  fi

  echo "$CONFIG_FILE 中嘅倉庫："
  echo ""

  local seen_paths=()
  while IFS= read -r repo_path; do
    # 跳過空行或注釋（但唔跳過暫停標記）
    if [[ -z "$repo_path" ]] || [[ "$repo_path" =~ ^# && ! "$repo_path" =~ ^${PAUSED_MARKER} ]]; then
      continue
    fi

    # 處理暫停嘅倉庫
    local is_paused=false
    if [[ "$repo_path" =~ ^${PAUSED_MARKER} ]]; then
      is_paused=true
      repo_path="${repo_path/#${PAUSED_MARKER}/}"
    fi

    # 展開波浪號
    local expanded_path="${repo_path/#\~/$HOME}"

    # 檢查重複
    local is_duplicate=false
    for seen in "${seen_paths[@]}"; do
      if [[ "$seen" == "$expanded_path" ]]; then
        is_duplicate=true
        break
      fi
    done

    if [[ "$is_duplicate" == "true" ]]; then
      echo "  $repo_path (重複，會被跳過)"
    else
      seen_paths+=("$expanded_path")
      if [[ -d "$expanded_path/.git" ]]; then
        if [[ "$is_paused" == "true" ]]; then
          echo "  $repo_path [已暫停]"
        else
          echo "  $repo_path"
        fi
      else
        echo "  $repo_path (唔係 git 倉庫或者唔存在)"
      fi
    fi
  done <"$CONFIG_FILE"

  echo ""
  echo "獨特倉庫總數：${#seen_paths[@]}"
}

show_status() {
  local os_type=$(detect_os)

  echo "Git 自動推送狀態"
  echo "===================="
  echo ""

  if [[ "$os_type" == "macos" ]]; then
    local plist_path="$MACOS_LAUNCHAGENTS_DIR/${MACOS_PLIST_NAME}.plist"

    if [[ ! -f "$plist_path" ]]; then
      echo "狀態：未安裝"
      echo "運行 '$0 install' 來安裝服務"
      exit 0
    fi

    echo "狀態：已安裝 (launchd)"
    echo "配置：$plist_path"
    echo "日誌：$MACOS_LOGS_DIR/${MACOS_PLIST_NAME}.log"
    echo ""

    if launchctl list | grep -q "$MACOS_PLIST_NAME"; then
      echo "服務：運行中"
      echo ""
      echo "下次運行：launchd 唔公開 StartInterval 嘅下次運行時間"
      echo "間隔：每 $INTERVAL_MINUTES 分鐘"
      echo ""
      echo "查看最近嘅運行記錄："
      echo "  tail -20 $MACOS_LOGS_DIR/${MACOS_PLIST_NAME}.log"
    else
      echo "服務：未加載"
      echo "運行：launchctl load $plist_path"
    fi
  elif [[ "$os_type" == "linux" ]]; then
    if [[ ! -f "$LINUX_SYSTEMD_USER_DIR/${LINUX_SERVICE_NAME}.timer" ]]; then
      echo "狀態：未安裝"
      echo "運行 '$0 install' 來安裝服務"
      exit 0
    fi

    echo "狀態：已安裝 (systemd)"
    echo "服務：$LINUX_SYSTEMD_USER_DIR/${LINUX_SERVICE_NAME}.service"
    echo "計時器：$LINUX_SYSTEMD_USER_DIR/${LINUX_SERVICE_NAME}.timer"
    echo ""

    # 獲取計時器狀態
    if systemctl --user is-active "${LINUX_SERVICE_NAME}.timer" >/dev/null 2>&1; then
      echo "服務：活動中"
      echo ""

      # 獲取下次運行時間
      local next_run=$(systemctl --user list-timers --no-pager | grep "${LINUX_SERVICE_NAME}.timer" | awk '{print $1, $2, $3}')
      if [[ -n "$next_run" ]]; then
        echo "下次運行：$next_run"
      fi

      echo ""
      echo "完整計時器信息："
      systemctl --user status "${LINUX_SERVICE_NAME}.timer" --no-pager | grep -A 5 "Trigger:"

      echo ""
      echo "最近嘅運行："
      journalctl --user -u "${LINUX_SERVICE_NAME}.service" -n 5 --no-pager
    else
      echo "服務：未活動"
      echo "運行：systemctl --user start ${LINUX_SERVICE_NAME}.timer"
    fi
  else
    echo "未知嘅操作系統類型"
    exit 1
  fi

  echo ""
  echo "配置：$CONFIG_FILE"

  if [[ -f "$CONFIG_FILE" ]]; then
    local repo_count=$(grep -v '^#' "$CONFIG_FILE" | grep -v '^$' | wc -l | tr -d ' ')
    echo "已配置倉庫：$repo_count"
  else
    echo "未找到配置文件"
  fi

  echo ""
  list_repos
}

process_repo() {
  local repo_path="$1"
  local seen_paths_ref=${2:-}

  # 檢查係咪暫停
  local is_paused=false
  if [[ "$repo_path" =~ ^\#PAUSED\# ]]; then
    is_paused=true
    repo_path="${repo_path/#\#PAUSED\#/}"
  fi

  if [[ -z "$repo_path" ]] || [[ "$repo_path" =~ ^# ]]; then
    return 0
  fi

  # 展開波浪號
  repo_path="${repo_path/#\~/$HOME}"

  # 如果暫停咗，跳過處理
  if [[ "$is_paused" == "true" ]]; then
    echo "跳過已暫停：$repo_path"
    return 0
  fi

  # 檢查重複
  for seen in "${seen_paths_ref[@]}"; do
    if [[ "$seen" == "$repo_path" ]]; then
      echo "跳過重複：$repo_path"
      return 0
    fi
  done

  # 加到已見路徑
  seen_paths_ref+=("$repo_path")

  if [[ ! -d "$repo_path" ]]; then
    echo "⚠ 目錄唔存在：$repo_path"
    return 1
  fi

  if [[ ! -d "$repo_path/.git" ]]; then
    echo "⚠ 唔係 git 倉庫：$repo_path"
    return 1
  fi

  echo "正在處理：$repo_path"

  cd "$repo_path" || return 1

  if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "  無需提交嘅更改"
  else
    git add -A
    git commit -m "Automatic save from git_auto_push.sh" || true
    echo "  ✓ 已提交更改"
  fi

  # 獲取遠端更新
  git fetch 2>/dev/null || {
    echo "  ⚠ 獲取遠端失敗"
    return 1
  }

  # 檢查係咪會產生合併提交
  local upstream_branch=$(git rev-parse --abbrev-ref @{u} 2>/dev/null)
  if [[ -n "$upstream_branch" ]]; then
    local commits_behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo "0")
    local commits_ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")

    if [[ "$commits_behind" -gt 0 ]] && [[ "$commits_ahead" -gt 0 ]]; then
      echo "  ✗ 檢測到分支分歧，會產生合併提交"
      echo "  本地領先：$commits_ahead 提交"
      echo "  遠端領先：$commits_behind 提交"
      send_notification "Git 自動推送 - 需要合併" "分支分歧於：$repo_path"
      return 1
    fi
  fi

  git pull --no-rebase --no-edit 2>&1 | tee /tmp/git_pull_output.txt

  # 檢查係咪有未合併嘅文件（使用 diff-filter=U）
  if git diff --diff-filter=U --name-only | grep -q .; then
    echo "  ✗ 合併過程中檢測到衝突"
    echo "  未合併嘅文件："
    git diff --diff-filter=U --name-only | sed 's/^/    /'
    git merge --abort 2>/dev/null || true
    send_notification "Git 自動推送 - 衝突" "衝突於：$repo_path"
    return 1
  fi

  if git push 2>&1; then
    echo "  ✓ 已推送更改"
  else
    echo "  ⚠ 推送失敗"
    return 1
  fi

  return 0
}

run_auto_push() {
  echo "=== Git 自動推送 - $(date) ==="

  # 加載 SSH 代理用於認證
  load_ssh_agent

  if [ ! -f "$CONFIG_FILE" ]; then
    echo "未找到配置文件：$CONFIG_FILE"
    echo "創建佢並加入倉庫路徑（每行一個）"
    exit 0
  fi

  if [ ! -s "$CONFIG_FILE" ]; then
    echo "配置文件係空嘅：$CONFIG_FILE"
    exit 0
  fi

  local seen_paths=()
  while IFS= read -r repo_path; do
    process_repo "$repo_path" seen_paths
    echo ""
  done <"$CONFIG_FILE"

  echo "=== 完成於 $(date) ==="
}

main() {
  case "${1:-}" in
  install)
    install_service
    ;;
  uninstall)
    uninstall_service
    ;;
  run)
    run_auto_push
    ;;
  add)
    add_current_dir
    ;;
  pause)
    pause_repo "${2:-}"
    ;;
  resume)
    resume_repo "${2:-}"
    ;;
  list)
    list_repos
    ;;
  status)
    show_status
    ;;
  *)
    echo "Git 自動推送腳本 ($SCRIPT_PATH)"
    echo ""
    echo "用法：$0 [命令]"
    echo ""
    echo "命令："
    echo "  install     安裝服務（macOS 用 launchd，Linux 用 systemd）"
    echo "  uninstall   卸載服務"
    echo "  run         運行一次自動推送過程"
    echo "  add         將當前目錄加到配置文件"
    echo "  pause [路徑] 暫停特定倉庫嘅自動推送（默認當前目錄）"
    echo "  resume [路徑] 恢復特定倉庫嘅自動推送（默認當前目錄）"
    echo "  list        列出配置文件中嘅所有倉庫"
    echo "  status      顯示服務狀態同下次運行時間"
    echo ""
    echo "配置文件：$CONFIG_FILE"
    echo "間隔：每 $INTERVAL_MINUTES 分鐘"
    exit 1
    ;;
  esac
}

main "$@"

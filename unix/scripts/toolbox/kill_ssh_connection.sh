#!/usr/bin/env bash

CONNECTION_PID=$(ps aux |
  grep ssh |
  grep -v sshd |
  grep -v ssh-agent |
  grep -v grep |
  grep -v kill_ssh_connection |
  fzf --height 100% --border -m --ansi |
  awk '{ print $2 }'
)

[[ -z "$CONNECTION_PID" ]] && exit 0

echo "kill $CONNECTION_PID"

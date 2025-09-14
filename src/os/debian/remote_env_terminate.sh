#!/bin/bash

# 喺 cronjob 上面按根執行。 AWS 實例應該設定為喺關機嗰陣終止。

LOGGED_IN_USERS=$(who | grep -c "pts") # Count active pseudo-terminals (SSH sessions)

if [ "$LOGGED_IN_USERS" -eq 0 ]; then
  if [ -f /tmp/aws_terminate_no_user ]; then
    MARKER_TIME=$(stat -c %Y /tmp/aws_terminate_no_user)
    CURRENT_TIME=$(date +%s)
    TIME_DIFF=$((CURRENT_TIME - MARKER_TIME))

    if [ "$TIME_DIFF" -ge 1800 ]; then # 1800 秒
      echo "30 分鐘冇 SSH 登入。閂緊機。" | wall
      sudo /sbin/shutdown -h now
    fi
  else
    touch /tmp/aws_terminate_no_user
  fi

  rm -f /tmp/aws_terminate_exists_user
else
  rm -f /tmp/aws_terminate_no_user
  touch /tmp/aws_terminate_exists_user
fi

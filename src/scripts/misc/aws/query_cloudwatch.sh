#!/usr/bin/env bash

set -euo pipefail
set -o pipefail

QUERY_ID="$1"

if [ -z "$QUERY_ID" ]; then
  # 這在 Mac 和 Linux 中是不同的
  START_TIME=$(date -d -30minutes +%s)
  END_TIME=$(date -d -0minutes +%s)

  QUERY='fields @message, @timestamp, @log
 | sort @timestamp desc
 | filter @message like /(?i)error/
 | limit 100'

  QUERY_ID=$(
    aws logs start-query \
      --log-group-name $LOG_GROUP_ID \
      --start-time $START_TIME \
      --end-time $END_TIME \
      --query-string "$QUERY" | jq -r '.queryId'
  )

  echo “查詢開始（查詢ID：$QUERY_ID），請稍等...” && sleep 5 # 給它一些時間來查詢
fi

aws logs get-query-results --query-id $QUERY_ID >/tmp/cloudwatch.json

echo "查詢寫入到 /tmp/cloudwatch.json"

cat /tmp/cloudwatch.json | jq | less

#!/usr/bin/env bash

set -e

# CPUQuota 會考慮到 CPU 嘅數量，喺 Surface 入面係4個

systemd-run --scope \
  -p CPUQuota=200% \
  -p MemoryMax=6048M \
  -p MemoryHigh=5500M \
  --user \
  google-chrome-stable &

echo "PID: $!"

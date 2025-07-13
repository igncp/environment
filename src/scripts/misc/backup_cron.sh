#!/usr/bin/env bash

set -euo pipefail

# Usage:
# 30 */2 * * * bash /home/igncp/.scripts/backup_cron_usr.sh
#
# And then in `backup_cron_usr.sh`:
# BACKUP_ZIP_PASS=somepass \
#   bash ~/development/environment/src/scripts/misc/backup_cron.sh

LOG_FILE=${LOG_FILE:-/tmp/cron-backup-log}
FILES_TO_KEEP_NUM=${FILES_TO_KEEP_NUM:-2}

echo '' >"$LOG_FILE"
date >>"$LOG_FILE"

if [ -f $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
  echo 'Sourcing nix' >>"$LOG_FILE"
  . $HOME/.nix-profile/etc/profile.d/nix.sh
fi
if [ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]; then
  echo 'Sourcing hm-nix' >>"$LOG_FILE"
  . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
fi

export PATH="$PATH:$HOME/.nix-profile/bin"

cd ~/development/environment

BACKUP_ENC_SKIP_PASS=true \
  bash ~/development/environment/src/scripts/backup.sh -c \
  >>"$LOG_FILE" 2>&1

TAIL_NUM=$(($FILES_TO_KEEP_NUM + 1))

FILES_TO_DELETE=$(find ~/cron-backups -type f | sort -Vr | tail -n +$TAIL_NUM)

for FILE_TO_DELETE in $FILES_TO_DELETE; do
  echo "Deleting $FILE_TO_DELETE" >>$LOG_FILE
  rm $FILE_TO_DELETE
done

echo "backup_cron.sh finished successfully" >>$LOG_FILE

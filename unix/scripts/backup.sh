#!/usr/bin/env bash

# Rename this file inside the project
# The part to change is between the `+++` lines
# Example usage: sh ~/project/scripts/backup.sh /mnt/backup_2022-01-02
    # Here, /mnt/backup_2022-01-02 should be a directory
# It keeps the uncompressed files in the path plus a password protected zip
# file with the same contents inside the directory

set -e

BACKUP_PATH="$1"
BACKUP_FILE="$(basename $BACKUP_PATH).zip"

if [ -z "$BACKUP_PATH" ]; then
  echo "Missing backup path as first argument"
  exit 1
fi

rsync -rh --delete ~/project/ "$BACKUP_PATH/project"
# +++ Add here the rest of things to copy
# ...
# +++

mkdir -p ~/backups/
sudo chown -R igncp "$BACKUP_PATH"
rm -rf "$BACKUP_PATH/$BACKUP_FILE"
rm -rf ~/backups/"$BACKUP_FILE"
echo "Input password for zip file"
zip -q -e -r ~/backups/"$BACKUP_FILE" "$BACKUP_PATH"
mv ~/backups/"$BACKUP_FILE" "$BACKUP_PATH"

echo "Upload $BACKUP_PATH/$BACKUP_FILE to the cloud"

echo "Backup finished successfully"
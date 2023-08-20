#!/usr/bin/env bash

# Copy this file inside the ~/development/environment/project folder as
# `backup.sh`.
#
# The part to change is between the `+++` lines
# Example usage: sh backup.sh /mnt/backup_laptop
    # Here, /mnt/backup_laptop should be a directory
#
# It keeps the uncompressed files in the path plus an encrypted and
# password-protected zip file with the same contents inside the directory

set -ex

BACKUP_PATH="$1"
BACKUP_FILE_ZIP="$(basename $BACKUP_PATH)-$(date +"%Y-%m-%d").zip"
BACKUP_FILE_AGE="$(basename $BACKUP_PATH)-$(date +"%Y-%m-%d").enc"

if [ -z "$BACKUP_PATH" ]; then
  echo "Missing backup path as first argument"
  exit 1
fi

rm -rf "$BACKUP_PATH"
mkdir -p "$BACKUP_PATH"

rsync -rh --delete /etc/hosts "$BACKUP_PATH/hosts"
rsync -rh --delete ~/development/environment/ "$BACKUP_PATH/environment/"
# +++ Add here the rest of things to copy (review checklist of things to backup)
# ...
# +++

mkdir -p ~/backups/
sudo chown -R $USER "$BACKUP_PATH"
rm -rf "$BACKUP_PATH/$BACKUP_FILE_ZIP"
rm -rf ~/backups/"$BACKUP_FILE_ZIP"
rm -rf ~/backups/"$BACKUP_FILE_AGE"
echo "Input password for zip file"
zip -q -e -r ~/backups/"$BACKUP_FILE_ZIP" "$BACKUP_PATH"
mv ~/backups/"$BACKUP_FILE_ZIP" "$BACKUP_PATH"
echo "Input password for .enc file"
age -e -p "$BACKUP_PATH/$BACKUP_FILE_ZIP" > "$BACKUP_PATH/$BACKUP_FILE_AGE"
rm -rf "$BACKUP_PATH/$BACKUP_FILE_ZIP"
rm -rf ~/backups/

echo "Remember to upload $BACKUP_PATH/$BACKUP_FILE_AGE to the cloud"

echo "Backup finished successfully"

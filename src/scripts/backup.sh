#!/usr/bin/env bash

# Copy this file inside the ~/development/environment/project folder as
# `backup.sh`.
#
# The part to change is between the `+++` lines
# Example usage: `bash backup.sh`
#
# It keeps the uncompressed files in the path plus an encrypted and
# password-protected zip file with the same contents inside the directory.
#
# You can pass `-u` as the first argument to upload the file to S3.
#
# If when unzipping the file there are data-corruption issues, use `7z x
# FILENAME.zip` to uncompress.

set -ex

# This should be a directory, don't add a slash at the end. **It will be
# removed**. Better to change than leaving the default.
BACKUP_PATH="$HOME/backup_env_$(hostname --short)"
S3_BUCKET_NAME="@TODO" # Optional, only used if `-u` is passed

BACKUP_FILE_ZIP="$(date +"%Y-%m-%d")-$(basename $BACKUP_PATH).zip"
BACKUP_FILE_AGE="$(date +"%Y-%m-%d")-$(basename $BACKUP_PATH).enc"

if [ -z "$BACKUP_PATH" ]; then
  echo "Missing backup path"
  exit 1
fi

rm -rf "$BACKUP_PATH"
mkdir -p "$BACKUP_PATH"

rsync -rh --delete /etc/hosts "$BACKUP_PATH/hosts"
rsync -rh --delete ~/development/environment/ "$BACKUP_PATH/environment/"
# +++ Add here the rest of things to copy (review checklist of things to backup)
# Examples:
# rsync -rh --delete ~/Downloads/ "$BACKUP_PATH/Downloads/"
# rsync -rh --delete ~/Document/ "$BACKUP_PATH/Documents/"
# rsync -rh --delete ~/misc/minecraft/world/ "$BACKUP_PATH/minecraft_world/"
# rsync -rh --delete --exclude=*.foo ~/RetroPie/roms/ "$BACKUP_PATH/retropie_roms/"
# rsync -rh --delete ~/.ssh/ "$BACKUP_PATH/ssh/"
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

if [ "$1" == "-u" ]; then
  aws cp $BACKUP_PATH/$BACKUP_FILE_AGE s3://$S3_BUCKET_NAME/$BACKUP_FILE_AGE
else
  echo "Remember to upload $BACKUP_/$BACKUP_FILE_AGE to the cloud"
fi

echo "Backup finished successfully"

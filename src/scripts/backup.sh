#!/usr/bin/env bash

# This file should be run directly or via `src/scripts/misc/backup_cron.sh`.
#
# It keeps the uncompressed files in the path plus an encrypted and
# password-protected zip file with the same contents inside the directory.
#
# You can pass `-u` as the first argument to upload the file to S3.
#
# If when unzipping the file there are data-corruption issues, use `7z x
# FILENAME.zip` to uncompress.
#
# The script should not use `sudo` or require root access since it can be run
# from a cron job.

set -ex

# This should be a directory, don't add a slash at the end. **It will be
# removed**. Better to change than leaving the default.
export BACKUP_PATH=${BACKUP_PATH:-"$HOME/backup_env_$(hostname --short)"}
S3_BUCKET_NAME="$S3_BUCKET_NAME" # Optional, only used if `-u` is passed

BACKUP_FILE_ZIP="$(date +"%Y-%m-%d-%H%M%S")-$(basename $BACKUP_PATH).zip"
BACKUP_FILE_AGE="$(date +"%Y-%m-%d-%H%M%S")-$(basename $BACKUP_PATH).enc"

set +x
BACKUP_ZIP_PASS="$BACKUP_ZIP_PASS"
set -x
BACKUP_ENC_SKIP_PASS="${BACKUP_ENC_SKIP_PASS:-false}"

if [ -z "$BACKUP_PATH" ]; then
  echo "Missing backup path"
  exit 1
fi

rm -rf "$BACKUP_PATH"
mkdir -p "$BACKUP_PATH"

bash ~/development/environment/project/backup.sh

mkdir -p ~/environment_backups/
rm -rf "$BACKUP_PATH/$BACKUP_FILE_ZIP"
rm -rf ~/environment_backups/"$BACKUP_FILE_ZIP"
rm -rf ~/environment_backups/"$BACKUP_FILE_AGE"
set +x
if [ -z "$BACKUP_ZIP_PASS" ]; then
  echo "Input password for zip file"
  set -x
  zip -q -e -r ~/environment_backups/"$BACKUP_FILE_ZIP" "$BACKUP_PATH"
else
  echo "Creating the zip file with the passed pass"
  zip -P "$BACKUP_ZIP_PASS" -q -r ~/environment_backups/"$BACKUP_FILE_ZIP" "$BACKUP_PATH"
  set -x
fi
mv ~/environment_backups/"$BACKUP_FILE_ZIP" "$BACKUP_PATH"
if [ "$BACKUP_ENC_SKIP_PASS" != "true" ]; then
  echo "Input password for .enc file"
  age -e -p "$BACKUP_PATH/$BACKUP_FILE_ZIP" >"$BACKUP_PATH/$BACKUP_FILE_AGE"
else
  BACKUP_FILE_AGE="$(echo $BACKUP_FILE_AGE | sed 's|.enc|_nopass.enc|')"
  rm -rf ~/environment_backups/"$BACKUP_FILE_AGE"
  cp "$BACKUP_PATH/$BACKUP_FILE_ZIP" "$BACKUP_PATH/$BACKUP_FILE_AGE"
fi
rm -rf "$BACKUP_PATH/$BACKUP_FILE_ZIP"
rm -rf ~/environment_backups/

if [ "$1" == "-u" ]; then
  aws cp $BACKUP_PATH/$BACKUP_FILE_AGE s3://$S3_BUCKET_NAME/$BACKUP_FILE_AGE
elif [ "$1" == "-c" ]; then
  mkdir -p ~/cron-backups
  mv "$BACKUP_PATH/$BACKUP_FILE_AGE" ~/cron-backups
  rm -rf "$BACKUP_PATH"
else
  echo "Remember to upload $BACKUP_PATH/$BACKUP_FILE_AGE to the cloud"
fi

echo "backup.sh finished successfully"

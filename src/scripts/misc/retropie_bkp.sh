#!/usr/bin/env bash

set -e

# cp \
#    ~/development/environment/src/project_templates/gaming_backup/.retropie_bkp_env.sh \
#    ~/development/environment/project/.retropie_bkp_env.sh
. ~/development/environment/project/.retropie_bkp_env.sh

export HOME="/home/$USER"
export PATH="$HOME/.nix-profile/bin:$PATH"
. ~/.nix-profile/etc/profile.d/nix.sh

FILE_NAME="roms_$(date +%y-%m-%d_%H.%M.%S).tar.gz"

rm -rf ~/backups
mkdir -p ~/backups/content
cp -r ~/RetroPie ~/backups/content/RetroPie
crontab -l | ag -v '^#' >~/backups/content/crontab
cp /opt/retropie/configs/all/retroarch.cfg ~/backups/content/
cp -r ~/.ssh ~/backups/content/
cp -r ~/development/environment/project/.config ~/backups/content/environment_config
cp -r ~/development/environment/project/.retropie_bkp_env.sh ~/backups/content/bkp_config
tar czf ~/backups/"$FILE_NAME" ~/backups/content

rsync -hv -e "ssh -i $HOME/.ssh/bkp-rom" \
  ~/backups/"$FILE_NAME" \
  "$LOCAL_DEV":

rm -rf ~/backups

echo "RetroPie 備份成功儲存: $FILE_NAME"

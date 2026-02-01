mkdir -p ~/.config/i3blocks

# @TODO: Conditional separators

cat >~/.scripts/i3blocks_memory.sh <<"EOF"
free -h | ag 'Mem' | awk '{ print "🪣 "$4" |"; }'
EOF
chmod +x ~/.scripts/i3blocks_memory.sh

cat >~/.scripts/i3blocks_disk.sh <<"EOF"
df -h / | tail -n 1 | awk '{ print "💿 / "$5" |"; }'
EOF
chmod +x ~/.scripts/i3blocks_disk.sh

cat >~/.scripts/i3blocks_ip.sh <<"EOF"
ip a | grep '192.*24 ' -o | sed 's-/24- |-' | sed 's|^|🌐 |'
EOF
chmod +x ~/.scripts/i3blocks_ip.sh

cat >~/.scripts/i3blocks_microphone.sh <<"EOF"
VOLUME_PER=$(pacmd list-sources | ag "\\*" --after=10 | ag "volume:" | ag -v base | ag -r "[0-9]+%" -o | head -n 1)
VOLUME=${VOLUME_PER::-1};
if [[ "$(( $VOLUME >= 70 ))" == "1" ]]; then
  VOLUME_STR="$VOLUME_PER"
else
  VOLUME_STR='<span color="#ffacae">'"$VOLUME_PER</span>"
fi
echo "🎙️ $VOLUME_STR |"
EOF
chmod +x ~/.scripts/i3blocks_microphone.sh

cat >~/.scripts/i3blocks_docker_containers.sh <<"EOF"
if ! type docker > /dev/null 2>&1 ; then
  exit 0
fi
RUNNING_CONTAINERS=$(docker ps -q | wc -l)
if [[ "$(( $RUNNING_CONTAINERS > 0 ))" == "1" ]]; then
  echo "🐋 $RUNNING_CONTAINERS |"
fi
EOF
chmod +x ~/.scripts/i3blocks_docker_containers.sh

cat >~/.config/i3blocks/config <<"EOF"
separator=false
separator_block_width=7
# -- global config end

[expressvpn]
command="__HOME/development/environment/src/scripts/misc/i3blocks/i3blocks_expressvpn"
interval=30

[docker_containers]
command="__HOME/.scripts/i3blocks_docker_containers.sh"
interval=30

[microphone]
command="__HOME/.scripts/i3blocks_microphone.sh"
markup=pango
interval=30

[disk]
command="__HOME/.scripts/i3blocks_disk.sh"
interval=10

[memory]
command="__HOME/.scripts/i3blocks_memory.sh"
interval=10

[ip]
command="__HOME/.scripts/i3blocks_ip.sh"
interval=10

[battery]
command="__HOME/development/environment/src/scripts/misc/i3blocks/i3blocks_battery"
markup=pango
interval=10

[epoch]
command=echo "🕒 $(date +'%Y-%m-%d %H:%M:%S') |"
interval=1
EOF

sed -i "s|__HOME|$HOME|g" ~/.config/i3blocks/config

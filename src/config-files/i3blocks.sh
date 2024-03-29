mkdir -p ~/.config/i3blocks

# @TODO: Conditional separators

cat > ~/.scripts/i3blocks_memory.sh <<"EOF"
free -h | ag 'Mem' | awk '{ print "🪣 "$4" |"; }'
EOF
chmod +x ~/.scripts/i3blocks_memory.sh

cat > ~/.scripts/i3blocks_disk.sh <<"EOF"
df -h / | tail -n 1 | awk '{ print "💿 / "$5" |"; }'
EOF
chmod +x ~/.scripts/i3blocks_disk.sh

cat > ~/.scripts/i3blocks_ip.sh <<"EOF"
ip a | grep '192.*24 ' -o | sed 's-/24- |-' | sed 's|^|🌐 |'
EOF
chmod +x ~/.scripts/i3blocks_ip.sh

cat > ~/.scripts/i3blocks_battery <<"EOF"
#!/usr/bin/env python3
#
# Copyright (C) 2016 James Murphy
# Licensed under the GPL version 2 only
#
# A battery indicator blocklet script for i3blocks

from subprocess import check_output

status = check_output(['acpi'], universal_newlines=True)

if not status:
    # stands for no battery found
    fulltext = "<span color='red'><span font='FontAwesome'>\uf00d \uf240</span></span>"
    percentleft = 100
else:
    # if there is more than one battery in one laptop, the percentage left is
    # available for each battery separately, although state and remaining
    # time for overall block is shown in the status of the first battery
    batteries = status.split("\n")
    state_batteries=[]
    commasplitstatus_batteries=[]
    percentleft_batteries=[]
    for battery in batteries:
        if battery!='':
            state_batteries.append(battery.split(": ")[1].split(", ")[0])
            commasplitstatus = battery.split(", ")
            percentleft_batteries.append(int(commasplitstatus[1].rstrip("%\n")))
            commasplitstatus_batteries.append(commasplitstatus)
    state = state_batteries[0]
    commasplitstatus = commasplitstatus_batteries[0]
    percentleft = int(sum(percentleft_batteries)/len(percentleft_batteries))
    # stands for charging
    FA_LIGHTNING = "<span color='yellow'><span font='FontAwesome'>\uf0e7</span></span>"

    # stands for plugged in
    FA_PLUG = "<span font='FontAwesome'>\uf1e6</span>"

    fulltext = ""
    timeleft = ""

    if state == "Discharging":
        time = commasplitstatus[-1].split()[0]
        time = ":".join(time.split(":")[0:2])
        timeleft = " ({})".format(time)
    elif state == "Full":
        fulltext = FA_PLUG + " "
    elif state == "Unknown":
        fulltext = "<span font='FontAwesome'>\uf128</span> "
    else:
        fulltext = FA_LIGHTNING + " " + FA_PLUG + " "

    def color(percent):
        if percent < 10:
            # exit code 33 will turn background red
            return "#FFFFFF"
        if percent < 20:
            return "#FF3300"
        if percent < 30:
            return "#FF6600"
        if percent < 40:
            return "#FF9900"
        if percent < 50:
            return "#FFCC00"
        if percent < 60:
            return "#FFFF00"
        if percent < 70:
            return "#FFFF33"
        if percent < 80:
            return "#FFFF66"
        return "#FFFFFF"

    form =  '<span color="{}">{}%</span>'
    fulltext += form.format(color(percentleft), percentleft)
    fulltext += timeleft

print(fulltext + ' <span color="white"> |</span>')

if percentleft < 10:
    exit(33)
EOF
chmod +x ~/.scripts/i3blocks_battery

cat > ~/.scripts/i3blocks_microphone.sh <<"EOF"
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

cat > ~/.scripts/i3blocks_docker_containers.sh <<"EOF"
if ! type docker > /dev/null 2>&1 ; then
  exit 0
fi
RUNNING_CONTAINERS=$(docker ps -q | wc -l)
if [[ "$(( $RUNNING_CONTAINERS > 0 ))" == "1" ]]; then
  echo "🐋 $RUNNING_CONTAINERS |"
fi
EOF
chmod +x ~/.scripts/i3blocks_docker_containers.sh

cat > ~/.scripts/i3blocks_location.sh <<"EOF"
if [ -f /home/igncp/development/environment/project/.config/inside ]; then
  echo "🏡 |"
else
  echo "🏢 |"
fi
EOF
chmod +x ~/.scripts/i3blocks_location.sh

cat > ~/.config/i3blocks/config <<"EOF"
separator=false
separator_block_width=7
# -- global config end

[location]
command="/home/igncp/.scripts/i3blocks_location.sh"
interval=30

[docker_containers]
command="/home/igncp/.scripts/i3blocks_docker_containers.sh"
interval=30

[microphone]
command="/home/igncp/.scripts/i3blocks_microphone.sh"
markup=pango
interval=30

[disk]
command="/home/igncp/.scripts/i3blocks_disk.sh"
interval=10

[memory]
command="/home/igncp/.scripts/i3blocks_memory.sh"
interval=10

[ip]
command="/home/igncp/.scripts/i3blocks_ip.sh"
interval=10

[battery]
command="/home/igncp/.scripts/i3blocks_battery"
markup=pango
interval=10

[epoch]
command=echo "🕒 $(date +'%Y-%m-%d %H:%M:%S') |"
interval=1
EOF

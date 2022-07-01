mkdir -p ~/.config/i3blocks

# @TODO: Conditional separators

# @TODO: Move this to the arch-only config
cat > ~/.scripts/i3blocks_updates.sh <<"EOF"
pacman -Sy > /dev/null
UPDATES="$(pacman -Sup | wc -l)"
if [ "$UPDATES" == "0" ]; then
  echo "🍹  |"
else
  echo "♻️ $UPDATES  |"
fi
EOF
chmod +x ~/.scripts/i3blocks_updates.sh

cat > ~/.scripts/i3blocks_memory.sh <<"EOF"
free -h | ag 'Mem' | awk '{ print "🪣 "$4"  |"; }'
EOF
chmod +x ~/.scripts/i3blocks_memory.sh

cat > ~/.scripts/i3blocks_disk.sh <<"EOF"
df -h / | tail -n 1 | awk '{ print "💿 / "$5"  |"; }'
EOF
chmod +x ~/.scripts/i3blocks_disk.sh

cat > ~/.scripts/i3blocks_ip.sh <<"EOF"
ip a | grep '192.*24 ' -o | sed 's-/24-   |-' | sed 's|^|🌐 |'
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

print(fulltext + ' <span color="white">  |</span>')

if percentleft < 10:
    exit(33)
EOF
chmod +x ~/.scripts/i3blocks_battery

cat > ~/.config/i3blocks/config <<"EOF"
separator=false
separator_block_width=7

[updates]
command="/home/igncp/.scripts/i3blocks_updates.sh"
interval=10

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
command=echo "🕒 $(date +'%Y-%m-%d %H:%M')  |"
interval=1
EOF

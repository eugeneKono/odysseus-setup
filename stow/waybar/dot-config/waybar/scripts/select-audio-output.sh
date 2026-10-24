#!/usr/bin/env bash

chosen=$(
pactl list sinks |
awk '
/Name:/ {
    name=$2
}

/Description:/ {
    desc=substr($0, index($0,$2))
    sinks[desc]=name
    print desc
}
' |
rofi -dmenu -p "Select Output"
)

[ -z "$chosen" ] && exit

sink=$(
pactl list sinks |
awk -v selected="$chosen" '
/Name:/ {
    name=$2
}

/Description:/ {
    desc=substr($0, index($0,$2))

    if (desc == selected) {
        print name
        exit
    }
}
'
)

pactl set-default-sink "$sink"

# Move active streams
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$input" "$sink"
done

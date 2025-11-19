#!/bin/bash

VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [[ $MUTED == "true" ]]; then
    ICON="󰖁"
    COLOR=0xffed8796
elif [ $VOLUME -gt 50 ]; then
    ICON="󰕾"
    COLOR=0xffcad3f5
elif [ $VOLUME -gt 0 ]; then
    ICON="󰖀"
    COLOR=0xffcad3f5
else
    ICON="󰕿"
    COLOR=0xff939ab7
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="${VOLUME}%"

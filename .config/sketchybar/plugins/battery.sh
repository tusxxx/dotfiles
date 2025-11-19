#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then
    exit 0
fi

if [[ $CHARGING != "" ]]; then
    ICON="󰂄"
    COLOR=0xffa6da95
elif [ $PERCENTAGE -gt 80 ]; then
    ICON="󰁹"
    COLOR=0xffa6da95
elif [ $PERCENTAGE -gt 60 ]; then
    ICON="󰂀"
    COLOR=0xffa6da95
elif [ $PERCENTAGE -gt 40 ]; then
    ICON="󰁾"
    COLOR=0xffeed49f
elif [ $PERCENTAGE -gt 20 ]; then
    ICON="󰁼"
    COLOR=0xfff5a97f
else
    ICON="󰁺"
    COLOR=0xffed8796
fi

sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="${PERCENTAGE}%"

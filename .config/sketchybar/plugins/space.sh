#!/bin/bash

if [ "$SELECTED" = "true" ]; then
    sketchybar --set $NAME background.color=0xff8aadf4 icon.color=0xff181926
else
    sketchybar --set $NAME background.color=0xff313244 icon.color=0xffcad3f5
fi

#!/bin/bash

CPU_USAGE=$(ps -A -o %cpu | awk '{s+=$1} END {print s}')
CPU_USAGE=$(printf "%.0f" $CPU_USAGE)

sketchybar --set $NAME label="${CPU_USAGE}%"

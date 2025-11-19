#!/bin/bash

MEMORY_USAGE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}' | sed 's/%//')

if [ -z "$MEMORY_USAGE" ]; then
    MEMORY_USAGE=$(vm_stat | awk '/Pages active/ {active=$3} /Pages wired/ {wired=$4} /Pages occupied/ {occupied=$5} /Pages free/ {free=$3} END {printf "%.0f", (active+wired+occupied)/(active+wired+occupied+free)*100}')
fi

sketchybar --set $NAME label="${MEMORY_USAGE}%"

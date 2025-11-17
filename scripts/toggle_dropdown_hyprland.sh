#!/bin/bash
# ========================================
# Hyprland Dropdown Terminal Toggle Script
# ========================================
# Скрипт для открытия/закрытия dropdown терминала в Hyprland
# Использование: ./toggle_dropdown_hyprland.sh

CLASS="dropdown"

# Проверяем, существует ли окно с классом dropdown
if hyprctl clients | grep -q "class: $CLASS"; then
    # Если существует - переключаем видимость
    hyprctl dispatch togglespecialworkspace dropdown
else
    # Если не существует - создаем новое окно
    WEZTERM_CLASS=$CLASS wezterm start &

    # Ждем появления окна
    sleep 0.2

    # Перемещаем в special workspace
    hyprctl dispatch movetoworkspacesilent special:dropdown,class:^($CLASS)$
    hyprctl dispatch togglespecialworkspace dropdown
fi

#!/bin/bash
# ========================================
# WezTerm Dropdown Terminal Toggle Script
# ========================================
# Скрипт для открытия/закрытия dropdown терминала
# Использование: ./toggle_dropdown.sh

WEZTERM_CLASS="dropdown"
WEZTERM_APP="WezTerm"

# Проверяем, запущен ли WezTerm в dropdown режиме
if pgrep -f "wezterm.*--class $WEZTERM_CLASS" > /dev/null; then
    # Если запущен - переключаем видимость окна
    osascript <<EOF
tell application "System Events"
    if exists (processes where name is "$WEZTERM_APP") then
        tell process "$WEZTERM_APP"
            set visible to not visible
        end tell
    end if
end tell
EOF
else
    # Если не запущен - запускаем в dropdown режиме
    WEZTERM_CLASS=$WEZTERM_CLASS /Applications/WezTerm.app/Contents/MacOS/wezterm start &

    # Ждем запуска и позиционируем окно
    sleep 0.5
    osascript <<EOF
tell application "System Events"
    tell process "$WEZTERM_APP"
        set position of front window to {0, 0}
        set size of front window to {1920, 600}
    end tell
end tell
EOF
fi

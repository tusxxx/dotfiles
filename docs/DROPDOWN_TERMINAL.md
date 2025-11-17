# Настройка Dropdown Terminal (Quake-mode)

Dropdown терминал - это терминал, который появляется по горячей клавише на пол экрана (как консоль в Quake) и скрывается той же клавишей, сохраняя историю.

## macOS

### Способ 1: Hammerspoon (Рекомендуется)

[Hammerspoon](https://www.hammerspoon.org/) - мощный инструмент автоматизации для macOS.

1. **Установка:**
   ```bash
   brew install --cask hammerspoon
   ```

2. **Конфигурация** (`~/.hammerspoon/init.lua`):
   ```lua
   -- Dropdown WezTerm
   local wezterm = nil
   local weztermBundleID = "com.github.wez.wezterm"

   -- Hotkey: Cmd+Shift+Space
   hs.hotkey.bind({"cmd", "shift"}, "space", function()
       if wezterm == nil or not wezterm:isRunning() then
           -- Запускаем WezTerm в dropdown режиме
           wezterm = hs.application.open(weztermBundleID, 1, true)
           hs.timer.doAfter(0.3, function()
               local win = wezterm:mainWindow()
               if win then
                   local screen = hs.screen.mainScreen()
                   local frame = screen:frame()
                   -- Позиционируем: полная ширина, 50% высоты, вверху экрана
                   win:setFrame({
                       x = frame.x,
                       y = frame.y,
                       w = frame.w,
                       h = frame.h * 0.5
                   })
               end
           end)
       else
           local win = wezterm:mainWindow()
           if win and win:isVisible() then
               -- Скрываем
               wezterm:hide()
           else
               -- Показываем и фокусируем
               wezterm:activate()
               local win = wezterm:mainWindow()
               if win then
                   win:focus()
               end
           end
       end
   end)
   ```

3. **Перезапустите Hammerspoon**

### Способ 2: Automator + System Shortcuts

1. **Создайте скрипт:**
   ```bash
   mkdir -p ~/dotfiles/scripts
   # Скрипт уже создан: ~/dotfiles/scripts/toggle_dropdown.sh
   ```

2. **Откройте Automator:**
   - Applications → Automator
   - New Document → Quick Action

3. **Настройте Quick Action:**
   - Workflow receives: `no input`
   - In: `any application`
   - Добавьте действие: `Run Shell Script`
   - Вставьте:
     ```bash
     ~/dotfiles/scripts/toggle_dropdown.sh
     ```

4. **Сохраните** как `Toggle WezTerm Dropdown`

5. **Назначьте горячую клавишу:**
   - System Settings → Keyboard → Keyboard Shortcuts
   - Services → General
   - Найдите `Toggle WezTerm Dropdown`
   - Назначьте: `Cmd+Shift+Space` (или другую)

### Способ 3: BetterTouchTool / Karabiner-Elements

Если используете эти инструменты, можете настроить горячую клавишу для запуска:
```bash
~/dotfiles/scripts/toggle_dropdown.sh
```

## Linux

### i3 / Sway

Добавьте в конфиг (`~/.config/i3/config` или `~/.config/sway/config`):

```
# Dropdown terminal
bindsym $mod+grave exec wezterm start --class dropdown
for_window [app_id="dropdown"] floating enable, resize set 100ppt 50ppt, move position 0 0
```

### Hyprland

**Способ 1: С использованием special workspace (Рекомендуется)**

1. **Создайте скрипт** `~/.config/hyprland/scripts/toggle_dropdown.sh`:
   ```bash
   #!/bin/bash
   CLASS="dropdown"

   if hyprctl clients | grep -q "class: $CLASS"; then
       hyprctl dispatch togglespecialworkspace dropdown
   else
       WEZTERM_CLASS=$CLASS wezterm start &
       sleep 0.2
       hyprctl dispatch movetoworkspacesilent special:dropdown,class:^($CLASS)$
       hyprctl dispatch togglespecialworkspace dropdown
   fi
   ```

2. **Сделайте исполняемым:**
   ```bash
   chmod +x ~/.config/hyprland/scripts/toggle_dropdown.sh
   ```

3. **Добавьте в** `~/.config/hypr/hyprland.conf`:
   ```
   # Window rules для dropdown
   windowrulev2 = float, class:^(dropdown)$
   windowrulev2 = size 100% 50%, class:^(dropdown)$
   windowrulev2 = move 0 0, class:^(dropdown)$
   windowrulev2 = workspace special:dropdown silent, class:^(dropdown)$
   windowrulev2 = opacity 0.90, class:^(dropdown)$

   # Настройка special workspace
   workspace = special:dropdown, gapsout:0, gapsin:0

   # Keybinding (Super + `)
   bind = SUPER, grave, exec, ~/.config/hyprland/scripts/toggle_dropdown.sh
   ```

4. **Или используйте готовый конфиг:**
   ```bash
   # Скопируйте конфиг
   cp ~/dotfiles/.config/hyprland/dropdown.conf ~/.config/hyprland/
   cp ~/dotfiles/scripts/toggle_dropdown_hyprland.sh ~/.config/hyprland/scripts/

   # Добавьте в hyprland.conf
   echo "source = ~/.config/hyprland/dropdown.conf" >> ~/.config/hypr/hyprland.conf

   # Перезагрузите конфиг
   hyprctl reload
   ```

**Способ 2: Простой вариант без special workspace**

Добавьте в `~/.config/hypr/hyprland.conf`:
```
# Window rules
windowrulev2 = float, class:^(dropdown)$
windowrulev2 = size 100% 50%, class:^(dropdown)$
windowrulev2 = move 0 0, class:^(dropdown)$

# Keybinding
bind = SUPER, grave, exec, WEZTERM_CLASS=dropdown wezterm start
```

**Опциональные настройки:**
```
# Убрать borders
windowrulev2 = noborder, class:^(dropdown)$

# Убрать rounded corners
windowrulev2 = norounding, class:^(dropdown)$

# Анимация slide
windowrulev2 = animation slide, class:^(dropdown)$
```

### GNOME / KDE

Используйте расширения:
- **GNOME**: [Dropdown Terminal](https://extensions.gnome.org/extension/442/drop-down-terminal/)
- **KDE**: Yakuake или настройка через KWin scripts

### Custom script для любого WM

```bash
#!/bin/bash
# ~/.local/bin/wezterm-dropdown

if pgrep -f "wezterm.*dropdown" > /dev/null; then
    # Переключаем видимость
    wmctrl -x -a dropdown || wmctrl -x -r dropdown -b toggle,hidden
else
    # Запускаем
    wezterm start --class dropdown &
    sleep 0.2
    # Позиционируем (1920x600 вверху экрана)
    wmctrl -x -r dropdown -e 0,0,0,1920,600
fi
```

Назначьте на горячую клавишу через настройки WM.

## Проверка

1. **Запустите терминал в dropdown режиме:**
   ```bash
   WEZTERM_CLASS=dropdown wezterm start
   ```

2. **Проверьте настройки:**
   - Окно должно быть меньше обычного
   - Повышенная прозрачность
   - Скрытый таббар

3. **Тестируйте горячую клавишу:**
   - Нажмите назначенную клавишу
   - Терминал должен появиться/скрыться
   - История команд сохраняется

## Кастомизация

Отредактируйте `.wezterm.lua`:

```lua
if is_dropdown_mode() then
  -- Измените размер
  config.initial_cols = 250  -- ширина
  config.initial_rows = 30   -- высота

  -- Настройте прозрачность
  config.window_background_opacity = 0.95

  -- Другие настройки...
end
```

## Troubleshooting

**Терминал не появляется:**
- Проверьте права: `chmod +x ~/dotfiles/scripts/toggle_dropdown.sh`
- Проверьте путь к WezTerm в скрипте

**Позиционирование не работает:**
- Для macOS: используйте Hammerspoon
- Для Linux: проверьте настройки WM

**Горячая клавиша не срабатывает:**
- Проверьте конфликты с другими приложениями
- Используйте другую комбинацию клавиш

## Сравнение методов

| Метод | Плюсы | Минусы |
|-------|-------|--------|
| **macOS (Hammerspoon)** | Полный контроль, автоматическое позиционирование | Требует Hammerspoon |
| **Hyprland** | Special workspace, smooth animations, native integration | Только для Hyprland |
| **i3/Sway** | Простая настройка, стабильная работа | Базовая функциональность |
| **Generic Linux** | Работает везде | Требует wmctrl, может глючить |

### Рекомендации по выбору

- **macOS** → Hammerspoon (лучший UX)
- **Hyprland** → Special workspace метод (красиво и функционально)
- **i3/Sway** → Встроенные window rules (просто и надежно)
- **GNOME/KDE** → Yakuake или Guake (специализированные решения)

## Альтернативы

Если WezTerm dropdown не подходит:
- **macOS**: iTerm2 (встроенный Hotkey Window)
- **Linux**: Guake, Tilda, Yakuake
- **Cross-platform**: Alacritty с оконным менеджером

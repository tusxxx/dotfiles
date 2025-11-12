-- ============================================================================
-- WEZTERM КОНФИГУРАЦИЯ
-- Универсальная конфигурация для Windows, macOS и Linux
-- ============================================================================
-- Автор: Claude AI
-- Последнее обновление: 2025-11-12
--
-- ИНСТРУКЦИЯ ПО УСТАНОВКЕ:
-- 1. Скопируйте этот файл в домашнюю директорию:
--    Windows: C:\Users\ВашеИмя\.wezterm.lua
--    macOS/Linux: ~/.wezterm.lua
-- 2. Перезапустите WezTerm
--
-- ВАЖНО ДЛЯ WINDOWS:
-- Если при запуске появляется ошибка про pwsh.exe:
-- - По умолчанию WezTerm автоматически выберет доступный шелл
-- - Если хотите указать конкретный шелл, найдите секцию
--   "ПЛАТФОРМЕННО-СПЕЦИФИЧНЫЕ НАСТРОЙКИ" и раскомментируйте нужную строку
-- - Доступные опции: cmd.exe (всегда есть), powershell.exe, pwsh.exe, wsl.exe
--
-- СТРУКТУРА ФАЙЛА:
-- [1] Импорты и инициализация
-- [2] Определение операционной системы
-- [3] Цветовая схема и внешний вид
-- [4] Шрифты
-- [5] Прозрачность и эффекты
-- [6] Табы и панели
-- [7] Горячие клавиши
-- [8] Дополнительные настройки
-- ============================================================================

-- [1] ИМПОРТЫ И ИНИЦИАЛИЗАЦИЯ
local wezterm = require('wezterm')
local config = wezterm.config_builder()
local act = wezterm.action

-- [2] ОПРЕДЕЛЕНИЕ ОПЕРАЦИОННОЙ СИСТЕМЫ
-- Эта функция помогает делать платформенно-специфичные настройки
local function is_windows()
  return wezterm.target_triple:find("windows") ~= nil
end

local function is_macos()
  return wezterm.target_triple:find("darwin") ~= nil
end

local function is_linux()
  return wezterm.target_triple:find("linux") ~= nil
end

-- ============================================================================
-- [3] ЦВЕТОВАЯ СХЕМА И ВНЕШНИЙ ВИД
-- ============================================================================

-- ЦВЕТОВАЯ СХЕМА
-- Доступные схемы: Tokyo Night, Catppuccin, Dracula, Nord, Solarized и др.
-- Полный список: https://wezfurlong.org/wezterm/colorschemes/index.html
-- РЕДАКТИРОВАНИЕ: Измените название схемы для смены темы
config.color_scheme = 'Tokyo Night'

-- АЛЬТЕРНАТИВНЫЕ КРАСИВЫЕ СХЕМЫ (раскомментируйте нужную):
-- config.color_scheme = 'Catppuccin Mocha'
-- config.color_scheme = 'Dracula'
-- config.color_scheme = 'Nord'
-- config.color_scheme = 'Gruvbox Dark'
-- config.color_scheme = 'OneDark'

-- КАСТОМНЫЕ ЦВЕТА
-- РЕДАКТИРОВАНИЕ: Настройте свои цвета для более тонкой кастомизации
config.colors = {
  -- Цвет фона и текста
  -- foreground = '#c0caf5',
  -- background = '#1a1b26',

  -- Цвет курсора
  cursor_bg = '#7aa2f7',
  cursor_fg = '#1a1b26',
  cursor_border = '#7aa2f7',

  -- Цвета табов
  tab_bar = {
    background = '#16161e',
    active_tab = {
      bg_color = '#7aa2f7',
      fg_color = '#16161e',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#292e42',
      fg_color = '#787c99',
    },
    inactive_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#c0caf5',
    },
    new_tab = {
      bg_color = '#16161e',
      fg_color = '#7aa2f7',
    },
    new_tab_hover = {
      bg_color = '#292e42',
      fg_color = '#7aa2f7',
    },
  },
}

-- ============================================================================
-- [4] ШРИФТЫ
-- ============================================================================

-- ОСНОВНОЙ ШРИФТ
-- РЕДАКТИРОВАНИЕ: Установите шрифт, который вам нравится
-- Популярные моноширинные шрифты: JetBrains Mono, Fira Code, Cascadia Code, Hack
config.font = wezterm.font_with_fallback({
  {
    family = 'JetBrains Mono',
    weight = 'Regular',
    harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }, -- Лигатуры
  },
  'Consolas', -- Fallback для Windows
  'Menlo',    -- Fallback для macOS
  'DejaVu Sans Mono', -- Fallback для Linux
})

-- РАЗМЕР ШРИФТА
-- РЕДАКТИРОВАНИЕ: Настройте размер под свой монитор и зрение
if is_macos() then
  config.font_size = 14.0  -- macOS обычно использует больший размер
elseif is_windows() then
  config.font_size = 11.0  -- Windows
else
  config.font_size = 12.0  -- Linux
end

-- НАСТРОЙКИ РЕНДЕРИНГА ШРИФТА
config.freetype_load_target = 'HorizontalLcd'
config.freetype_render_target = 'HorizontalLcd'

-- ============================================================================
-- [5] ПРОЗРАЧНОСТЬ И ЭФФЕКТЫ
-- ============================================================================

-- ПРОЗРАЧНОСТЬ ОКНА
-- РЕДАКТИРОВАНИЕ: Значения от 0.0 (полностью прозрачный) до 1.0 (непрозрачный)
config.window_background_opacity = 0.85

-- ЭФФЕКТ РАЗМЫТИЯ (работает на macOS и некоторых Linux WM)
-- РЕДАКТИРОВАНИЕ: Настройте силу размытия
if is_macos() then
  config.macos_window_background_blur = 20
end

-- АКРИЛОВЫЙ ЭФФЕКТ НА WINDOWS
-- РЕДАКТИРОВАНИЕ: Включает/выключает акриловую прозрачность на Windows 10/11
if is_windows() then
  config.win32_system_backdrop = 'Acrylic' -- 'Disable', 'Acrylic', 'Mica', 'Tabbed'
end

-- АЛЬТЕРНАТИВА: Использование фонового изображения
-- РЕДАКТИРОВАНИЕ: Раскомментируйте и укажите путь к изображению
-- config.window_background_image = '/path/to/your/image.jpg'
-- config.window_background_image_hsb = {
--   brightness = 0.3,  -- Затемнение изображения
--   hue = 1.0,
--   saturation = 1.0,
-- }

-- ============================================================================
-- [6] ТАБЫ И ПАНЕЛИ
-- ============================================================================

-- ПОКАЗ ТАББАРА
-- РЕДАКТИРОВАНИЕ: Настройте отображение таббара
config.enable_tab_bar = true
config.use_fancy_tab_bar = false  -- false = компактный стиль
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false  -- true = таббар снизу

-- МАКСИМАЛЬНАЯ ШИРИНА ТАБА
config.tab_max_width = 32

-- ФОРМАТИРОВАНИЕ ЗАГОЛОВКА ТАБА
-- РЕДАКТИРОВАНИЕ: Настройте отображение информации в табах
wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title

  -- Если заголовок не задан явно, используем название процесса
  if title and #title > 0 then
    title = title
  else
    title = tab.active_pane.title
  end

  -- Добавляем номер таба
  return {
    { Text = ' ' .. tab.tab_index + 1 .. ': ' .. title .. ' ' },
  }
end)

-- ============================================================================
-- [7] ГОРЯЧИЕ КЛАВИШИ
-- ============================================================================

-- МОДИФИКАТОР КЛАВИШ
-- РЕДАКТИРОВАНИЕ: Измените модификатор под свои предпочтения
-- 'CTRL' - для Windows/Linux, 'CMD' - для macOS
local mod = is_macos() and 'CMD' or 'CTRL'
local mod_shift = is_macos() and 'CMD|SHIFT' or 'CTRL|SHIFT'

-- ГОРЯЧИЕ КЛАВИШИ
-- РЕДАКТИРОВАНИЕ: Добавьте или измените комбинации клавиш
config.keys = {
  -- ===== УПРАВЛЕНИЕ ТАБАМИ =====
  -- Создать новый таб
  { key = 't', mods = mod, action = act.SpawnTab('CurrentPaneDomain') },
  -- Закрыть текущий таб
  { key = 'q', mods = mod, action = act.CloseCurrentTab({ confirm = true }) },
  -- Переключение между табами
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  -- Переключение на конкретный таб (1-9)
  { key = '1', mods = mod, action = act.ActivateTab(0) },
  { key = '2', mods = mod, action = act.ActivateTab(1) },
  { key = '3', mods = mod, action = act.ActivateTab(2) },
  { key = '4', mods = mod, action = act.ActivateTab(3) },
  { key = '5', mods = mod, action = act.ActivateTab(4) },
  { key = '6', mods = mod, action = act.ActivateTab(5) },
  { key = '7', mods = mod, action = act.ActivateTab(6) },
  { key = '8', mods = mod, action = act.ActivateTab(7) },
  { key = '9', mods = mod, action = act.ActivateTab(8) },

  -- ===== УПРАВЛЕНИЕ ПАНЕЛЯМИ (PANES) =====
  -- Разделить по горизонтали
  { key = 'd', mods = mod, action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  -- Разделить по вертикали
  { key = 's', mods = mod, action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  -- Закрыть панель
  { key = 'w', mods = mod, action = act.CloseCurrentPane({ confirm = true }) },
  -- Навигация между панелями
  { key = 'LeftArrow', mods = mod, action = act.ActivatePaneDirection('Left') },
  { key = 'RightArrow', mods = mod, action = act.ActivatePaneDirection('Right') },
  { key = 'UpArrow', mods = mod, action = act.ActivatePaneDirection('Up') },
  { key = 'DownArrow', mods = mod, action = act.ActivatePaneDirection('Down') },
  -- Изменение размера панели
  { key = 'LeftArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize({ 'Left', 5 }) },
  { key = 'RightArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize({ 'Right', 5 }) },
  { key = 'UpArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize({ 'Up', 5 }) },
  { key = 'DownArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize({ 'Down', 5 }) },

  -- ===== КОПИРОВАНИЕ И ВСТАВКА =====
  { key = 'c', mods = mod, action = act.CopyTo('Clipboard') },
  { key = 'v', mods = mod, action = act.PasteFrom('Clipboard') },

  -- ===== ПОИСК =====
  { key = 'f', mods = mod, action = act.Search('CurrentSelectionOrEmptyString') },

  -- ===== МАСШТАБИРОВАНИЕ ШРИФТА =====
  { key = '=', mods = mod, action = act.IncreaseFontSize },
  { key = '-', mods = mod, action = act.DecreaseFontSize },
  { key = '0', mods = mod, action = act.ResetFontSize },

  -- ===== ПОЛНОЭКРАННЫЙ РЕЖИМ =====
  { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },

  -- ===== КОПИРОВАНИЕ РЕЖИМА =====
  { key = 'x', mods = mod_shift, action = act.ActivateCopyMode },

  -- ===== БЫСТРЫЙ ВЫБОР (QuickSelect) =====
  { key = 'Space', mods = mod_shift, action = act.QuickSelect },

  -- ===== COMMAND PALETTE =====
  { key = 'p', mods = mod_shift, action = act.ActivateCommandPalette },

  -- ===== ОТЛАДКА =====
  { key = 'l', mods = mod_shift, action = act.ShowDebugOverlay },
}

-- ОТКЛЮЧЕНИЕ ДЕФОЛТНЫХ ПРИВЯЗОК
-- РЕДАКТИРОВАНИЕ: Раскомментируйте, если хотите начать с чистого листа
-- config.disable_default_key_bindings = true

-- ============================================================================
-- [8] ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ
-- ============================================================================

-- ОКНО
-- РЕДАКТИРОВАНИЕ: Настройте размер и поведение окна
config.initial_cols = 120  -- Ширина окна в колонках
config.initial_rows = 30   -- Высота окна в строках
config.window_decorations = "RESIZE"  -- "NONE" | "TITLE" | "RESIZE" | "TITLE | RESIZE"
config.window_close_confirmation = 'AlwaysPrompt'  -- Подтверждение при закрытии
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

-- ПОВЕДЕНИЕ ПРИ ЗАВЕРШЕНИИ ПРОЦЕССА
-- РЕДАКТИРОВАНИЕ: Настройте поведение при выходе из шелла
-- "CloseOnCleanExit" - закрывать только при нормальном выходе (код 0)
-- "Close" - всегда закрывать
-- "Hold" - всегда держать окно открытым
config.exit_behavior = "CloseOnCleanExit"  -- Рекомендуется для отладки

-- СКРОЛЛБЭК
-- РЕДАКТИРОВАНИЕ: Количество строк истории (чем больше, тем больше памяти)
config.scrollback_lines = 10000

-- КУРСОР
-- РЕДАКТИРОВАНИЕ: Настройте внешний вид курсора
config.default_cursor_style = 'BlinkingUnderline'  -- 'BlinkingBlock', 'SteadyBlock', 'BlinkingUnderline', etc.
config.cursor_blink_rate = 700  -- Скорость мигания в миллисекундах
config.cursor_thickness = 2

-- ПОВЕДЕНИЕ ПРОКРУТКИ
config.enable_scroll_bar = false  -- true = показывать полосу прокрутки
config.alternate_buffer_wheel_scroll_speed = 1

-- ПРОИЗВОДИТЕЛЬНОСТЬ
-- РЕДАКТИРОВАНИЕ: Настройте для оптимизации производительности
config.front_end = "WebGpu"  -- "OpenGL" | "WebGpu" | "Software"
config.max_fps = 60
config.animation_fps = 60

-- ЗВУКОВЫЕ УВЕДОМЛЕНИЯ
-- РЕДАКТИРОВАНИЕ: Включить/выключить звуковой сигнал
config.audible_bell = "Disabled"  -- "SystemBeep" | "Disabled"
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
}

-- ГИПЕРССЫЛКИ
-- РЕДАКТИРОВАНИЕ: Настройте правила для кликабельных ссылок
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Добавляем дополнительные правила для путей к файлам
table.insert(config.hyperlink_rules, {
  regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
  format = 'https://www.github.com/$1/$3',
})

-- АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ
-- РЕДАКТИРОВАНИЕ: Настройте проверку обновлений
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400  -- Раз в день

-- ЭМОДЗИ И UNICODE
config.unicode_version = 14

-- ПЛАТФОРМЕННО-СПЕЦИФИЧНЫЕ НАСТРОЙКИ
if is_macos() then
  -- macOS специфичные настройки
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = false
  config.native_macos_fullscreen_mode = false
elseif is_windows() then
  -- Windows специфичные настройки
  -- Автоматический выбор доступного шелла
  -- РЕДАКТИРОВАНИЕ: Раскомментируйте нужный шелл или оставьте закомментированным для автовыбора
  -- config.default_prog = { 'pwsh.exe' }        -- PowerShell Core 7+ (если установлен)
  -- config.default_prog = { 'powershell.exe' }  -- Windows PowerShell 5.1
  -- config.default_prog = { 'cmd.exe' }         -- Командная строка Windows
  -- config.default_prog = { 'wsl.exe' }         -- Windows Subsystem for Linux
  -- config.default_prog = { 'wsl.exe', '-d', 'Ubuntu' }  -- Конкретный дистрибутив WSL

  -- Если не указано, WezTerm автоматически выберет доступный шелл
elseif is_linux() then
  -- Linux специфичные настройки
  config.enable_wayland = true  -- Включить поддержку Wayland если доступна
end

-- ============================================================================
-- СТАТУСНАЯ СТРОКА (ДОПОЛНИТЕЛЬНО)
-- ============================================================================
-- РЕДАКТИРОВАНИЕ: Раскомментируйте для добавления кастомной статусной строки

-- wezterm.on('update-right-status', function(window, pane)
--   local date = wezterm.strftime('%Y-%m-%d %H:%M:%S')
--   local bat = ''
--   for _, b in ipairs(wezterm.battery_info()) do
--     bat = '🔋 ' .. string.format('%.0f%%', b.state_of_charge * 100)
--   end
--   window:set_right_status(wezterm.format({
--     { Text = bat .. '   ' .. date .. ' ' },
--   }))
-- end)

-- Фокус по наведению мыши
config.pane_focus_follows_mouse = true

-- ============================================================================
-- ВОЗВРАТ КОНФИГУРАЦИИ
-- ============================================================================

return config

-- ============================================================================
-- КОНЕЦ КОНФИГУРАЦИИ
-- ============================================================================
--
-- ПОЛЕЗНЫЕ ССЫЛКИ:
-- - Документация: https://wezfurlong.org/wezterm/
-- - Цветовые схемы: https://wezfurlong.org/wezterm/colorschemes/
-- - Конфигурационные опции: https://wezfurlong.org/wezterm/config/files.html
-- - Горячие клавиши: https://wezfurlong.org/wezterm/config/keys.html
--
-- СОВЕТЫ ДЛЯ РЕДАКТИРОВАНИЯ:
-- 1. Всегда ищите комментарии "РЕДАКТИРОВАНИЕ:" для быстрого нахождения настроек
-- 2. Перезапустите WezTerm после изменения конфига (или нажмите CTRL+SHIFT+R)
-- 3. Используйте CTRL+SHIFT+L для отладки и просмотра логов
-- 4. Начинайте с малых изменений и тестируйте каждое
-- 5. Храните резервную копию перед большими изменениями
-- ============================================================================

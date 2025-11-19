#!/bin/bash

# ========================================
# Dotfiles Installation Script
# ========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Installation flags
INSTALL_ZSH=false
INSTALL_WEZTERM=false
INSTALL_STARSHIP=false
INSTALL_SKETCHYBAR=false
INSTALL_YABAI=false
INSTALL_DROPDOWN=false

# ====== Helper Functions ======

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="macos"
            ;;
        Linux*)
            OS="linux"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO=$ID
            fi
            ;;
        *)
            OS="unknown"
            print_error "Unknown OS"
            exit 1
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup existing file
backup_file() {
    local file=$1
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$file" "$BACKUP_DIR/"
        print_warning "Backed up: $file -> $BACKUP_DIR/"
    fi
}

# Create symlink
create_symlink() {
    local source=$1
    local target=$2

    if [ -L "$target" ]; then
        print_info "Removing old symlink: $target"
        rm "$target"
    elif [ -e "$target" ]; then
        backup_file "$target"
        rm -rf "$target"
    fi

    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    print_success "Linked: $source -> $target"
}

# ====== Installation Functions ======

install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

install_package_macos() {
    local package=$1
    local tap=$2

    if [ -n "$tap" ] && ! brew tap | grep -q "$tap"; then
        brew tap "$tap"
    fi

    if brew list "$package" &>/dev/null; then
        print_info "$package already installed"
    else
        print_info "Installing $package..."
        brew install "$package"
        print_success "$package installed"
    fi
}

install_cask_macos() {
    local cask=$1

    if brew list --cask "$cask" &>/dev/null; then
        print_info "$cask already installed"
    else
        print_info "Installing $cask..."
        brew install --cask "$cask"
        print_success "$cask installed"
    fi
}

install_starship_linux() {
    if ! command_exists starship; then
        print_info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship installed"
    else
        print_info "Starship already installed"
    fi
}

# ====== Component Installation Functions ======

setup_zsh() {
    print_info "Setting up Zsh..."

    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to zsh..."
        if command_exists zsh; then
            chsh -s "$(which zsh)"
            print_success "Default shell changed to zsh"
            print_warning "Please log out and log back in for the change to take effect"
        else
            print_warning "zsh not found, please install it manually"
        fi
    fi

    print_success "Zsh configured"
    echo ""
}

setup_wezterm() {
    print_info "Setting up WezTerm..."

    case "$OS" in
        macos)
            install_cask_macos "wezterm"
            ;;
        linux)
            if ! command_exists wezterm; then
                print_warning "WezTerm not found. Install manually from: https://wezfurlong.org/wezterm/"
            fi
            ;;
    esac

    create_symlink "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
    print_success "WezTerm configured"
    echo ""
}

setup_starship() {
    print_info "Setting up Starship..."

    case "$OS" in
        macos)
            install_homebrew
            install_package_macos "starship"
            ;;
        linux)
            install_starship_linux
            ;;
    esac

    create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
    print_success "Starship configured"
    echo ""
}

setup_sketchybar() {
    if [ "$OS" != "macos" ]; then
        print_warning "SketchyBar is macOS only"
        return
    fi

    print_info "Setting up SketchyBar..."

    install_homebrew
    install_package_macos "sketchybar" "FelixKratz/formulae"
    install_cask_macos "font-fira-code-nerd-font"

    create_symlink "$DOTFILES_DIR/.config/sketchybar" "$HOME/.config/sketchybar"

    print_info "Starting SketchyBar..."
    brew services start sketchybar 2>/dev/null || sketchybar --reload 2>/dev/null || true

    print_success "SketchyBar configured and started"
    echo ""
}

setup_yabai() {
    if [ "$OS" != "macos" ]; then
        print_warning "Yabai is macOS only"
        return
    fi

    print_info "Setting up Yabai and skhd..."

    install_homebrew
    install_package_macos "koekeishiya/formulae/yabai"
    install_package_macos "koekeishiya/formulae/skhd"

    create_symlink "$DOTFILES_DIR/.config/yabai" "$HOME/.config/yabai"
    create_symlink "$DOTFILES_DIR/.config/skhd" "$HOME/.config/skhd"

    echo ""
    print_warning "IMPORTANT: Yabai requires additional setup for full functionality"
    print_info "1. Disable System Integrity Protection (SIP) for window management"
    print_info "2. Install scripting addition: sudo yabai --install-sa"
    print_info "3. Grant Accessibility permissions in System Settings"
    print_info "4. See: https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)"
    echo ""

    read -p "Start yabai and skhd services now? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        brew services start yabai
        brew services start skhd
        print_success "Yabai and skhd services started"
    fi

    print_success "Yabai and skhd configured"
    echo ""
}

setup_dropdown_terminal() {
    print_info "Setting up dropdown terminal..."

    case "$OS" in
        macos)
            if ! brew list --cask hammerspoon &>/dev/null; then
                print_info "Installing Hammerspoon..."
                brew install --cask hammerspoon
            fi

            mkdir -p "$HOME/.hammerspoon"

            if [ ! -f "$HOME/.hammerspoon/init.lua" ]; then
                cat > "$HOME/.hammerspoon/init.lua" <<'EOF'
-- ========================================
-- Hammerspoon Configuration
-- ========================================

-- Dropdown WezTerm Terminal
local wezterm = nil
local weztermBundleID = "com.github.wez.wezterm"

-- Hotkey: Cmd+Shift+Space
hs.hotkey.bind({"cmd", "shift"}, "space", function()
    if wezterm == nil or not wezterm:isRunning() then
        wezterm = hs.application.open(weztermBundleID, 1, true)
        hs.timer.doAfter(0.3, function()
            local win = wezterm:mainWindow()
            if win then
                local screen = hs.screen.mainScreen()
                local frame = screen:frame()
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
            wezterm:hide()
        else
            wezterm:activate()
            local win = wezterm:mainWindow()
            if win then
                win:focus()
            end
        end
    end
end)

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
    hs.reload()
end):start()

hs.alert.show("Hammerspoon Config Loaded")
EOF
                print_success "Hammerspoon config created"
            else
                print_info "Hammerspoon config already exists"
            fi

            open -a Hammerspoon 2>/dev/null || true
            print_success "Dropdown terminal configured (Cmd+Shift+Space)"
            ;;

        linux)
            if command_exists hyprctl || [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
                mkdir -p "$HOME/.config/hyprland/scripts"

                create_symlink "$DOTFILES_DIR/.config/hyprland/dropdown.conf" "$HOME/.config/hyprland/dropdown.conf"

                if [ -f "$DOTFILES_DIR/scripts/toggle_dropdown_hyprland.sh" ]; then
                    cp "$DOTFILES_DIR/scripts/toggle_dropdown_hyprland.sh" "$HOME/.config/hyprland/scripts/toggle_dropdown.sh"
                    chmod +x "$HOME/.config/hyprland/scripts/toggle_dropdown.sh"
                fi

                if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
                    if ! grep -q "source.*hyprland/dropdown.conf" "$HOME/.config/hypr/hyprland.conf"; then
                        echo "" >> "$HOME/.config/hypr/hyprland.conf"
                        echo "source = ~/.config/hyprland/dropdown.conf" >> "$HOME/.config/hypr/hyprland.conf"
                        hyprctl reload 2>/dev/null || true
                    fi
                fi

                print_success "Hyprland dropdown terminal configured (Super+\`)"
            else
                print_info "For dropdown terminal setup on other WMs, see docs/DROPDOWN_TERMINAL.md"
            fi
            ;;
    esac

    echo ""
}

# ====== Interactive Menu ======

show_menu() {
    echo ""
    echo "======================================"
    echo "  Dotfiles Installation"
    echo "======================================"
    echo ""
    echo "Detected OS: $OS"
    echo ""
    echo "Select components to install:"
    echo ""
    echo "  1) Zsh configuration"
    echo "  2) WezTerm terminal"
    echo "  3) Starship prompt"

    if [ "$OS" = "macos" ]; then
        echo "  4) SketchyBar (macOS status bar)"
        echo "  5) Yabai + skhd (window manager)"
    fi

    echo "  6) Dropdown terminal (Quake-mode)"
    echo ""
    echo "  a) Install all components"
    echo "  c) Continue with selected components"
    echo "  q) Quit"
    echo ""
}

toggle_component() {
    case $1 in
        1) INSTALL_ZSH=true ;;
        2) INSTALL_WEZTERM=true ;;
        3) INSTALL_STARSHIP=true ;;
        4)
            if [ "$OS" = "macos" ]; then
                INSTALL_SKETCHYBAR=true
            fi
            ;;
        5)
            if [ "$OS" = "macos" ]; then
                INSTALL_YABAI=true
            fi
            ;;
        6) INSTALL_DROPDOWN=true ;;
        a|A)
            INSTALL_ZSH=true
            INSTALL_WEZTERM=true
            INSTALL_STARSHIP=true
            if [ "$OS" = "macos" ]; then
                INSTALL_SKETCHYBAR=true
                INSTALL_YABAI=true
            fi
            INSTALL_DROPDOWN=true
            return 1
            ;;
        c|C)
            return 1
            ;;
        q|Q)
            print_info "Installation cancelled"
            exit 0
            ;;
    esac
    return 0
}

show_selected() {
    echo ""
    echo "Selected components:"
    $INSTALL_ZSH && echo "  ✓ Zsh"
    $INSTALL_WEZTERM && echo "  ✓ WezTerm"
    $INSTALL_STARSHIP && echo "  ✓ Starship"
    $INSTALL_SKETCHYBAR && [ "$OS" = "macos" ] && echo "  ✓ SketchyBar"
    $INSTALL_YABAI && [ "$OS" = "macos" ] && echo "  ✓ Yabai + skhd"
    $INSTALL_DROPDOWN && echo "  ✓ Dropdown terminal"
    echo ""
}

interactive_menu() {
    while true; do
        show_menu
        show_selected
        read -p "Enter choice (or 'c' to continue): " choice

        if ! toggle_component "$choice"; then
            break
        fi
    done
}

# ====== Installation Process ======

run_installation() {
    echo ""
    echo "======================================"
    echo "  Starting Installation"
    echo "======================================"
    echo ""

    if [ "$OS" = "macos" ]; then
        install_homebrew
    fi

    $INSTALL_ZSH && setup_zsh
    $INSTALL_WEZTERM && setup_wezterm
    $INSTALL_STARSHIP && setup_starship
    $INSTALL_SKETCHYBAR && setup_sketchybar
    $INSTALL_YABAI && setup_yabai
    $INSTALL_DROPDOWN && setup_dropdown_terminal

    # Setup fzf if available
    if command_exists fzf; then
        case "$OS" in
            macos)
                if [ -f /opt/homebrew/opt/fzf/install ]; then
                    /opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc
                elif [ -f /usr/local/opt/fzf/install ]; then
                    /usr/local/opt/fzf/install --key-bindings --completion --no-update-rc
                fi
                ;;
        esac
    fi

    echo ""
    echo "======================================"
    print_success "Installation completed!"
    echo "======================================"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"

    if $INSTALL_WEZTERM; then
        echo "  2. Restart WezTerm to apply configs"
    fi

    if $INSTALL_DROPDOWN; then
        if [ "$OS" = "macos" ]; then
            echo "  3. Use Cmd+Shift+Space for dropdown terminal"
        else
            echo "  3. Use Super+\` for dropdown terminal (Hyprland)"
        fi
    fi

    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        print_info "Backups saved to: $BACKUP_DIR"
    fi

    echo ""
}

# ====== Main ======

main() {
    detect_os

    # Check for --auto flag for non-interactive installation
    if [ "$1" = "--auto" ] || [ "$1" = "-a" ]; then
        print_info "Running automatic installation (all components)..."
        INSTALL_ZSH=true
        INSTALL_WEZTERM=true
        INSTALL_STARSHIP=true
        if [ "$OS" = "macos" ]; then
            INSTALL_SKETCHYBAR=true
            INSTALL_YABAI=true
        fi
        INSTALL_DROPDOWN=true
    else
        interactive_menu
    fi

    # Check if any component selected
    if ! $INSTALL_ZSH && ! $INSTALL_WEZTERM && ! $INSTALL_STARSHIP && \
       ! $INSTALL_SKETCHYBAR && ! $INSTALL_YABAI && ! $INSTALL_DROPDOWN; then
        print_warning "No components selected"
        exit 0
    fi

    run_installation
}

main "$@"

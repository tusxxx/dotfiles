#!/bin/bash

# ========================================
# Dotfiles Uninstallation Script
# ========================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
            ;;
        *)
            OS="unknown"
            ;;
    esac
}

# Check if symlink points to dotfiles
is_dotfiles_link() {
    local target=$1
    local dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -L "$target" ]; then
        local link_dest=$(readlink "$target")
        if [[ "$link_dest" == "$dotfiles_dir"* ]]; then
            return 0
        fi
    fi
    return 1
}

# Remove symlink
remove_symlink() {
    local target=$1
    local name=$2

    if [ -L "$target" ]; then
        rm "$target"
        print_success "Removed: $name"
        return 0
    elif [ -e "$target" ]; then
        print_warning "Not a symlink, skipping: $name"
        return 1
    else
        print_info "Not found: $name"
        return 1
    fi
}

# ====== Uninstall Functions ======

uninstall_zsh() {
    print_info "Removing zsh configuration..."
    remove_symlink "$HOME/.zshrc" "~/.zshrc"
    echo ""
}

uninstall_wezterm() {
    print_info "Removing WezTerm configuration..."
    remove_symlink "$HOME/.wezterm.lua" "~/.wezterm.lua"
    echo ""
}

uninstall_starship() {
    print_info "Removing Starship configuration..."
    remove_symlink "$HOME/.config/starship.toml" "~/.config/starship.toml"
    echo ""
}

uninstall_sketchybar() {
    print_info "Removing SketchyBar configuration..."

    # Stop SketchyBar if running
    if [ "$OS" = "macos" ] && command -v sketchybar >/dev/null 2>&1; then
        print_info "Stopping SketchyBar..."
        brew services stop sketchybar 2>/dev/null || true
        killall sketchybar 2>/dev/null || true
    fi

    remove_symlink "$HOME/.config/sketchybar" "~/.config/sketchybar"
    echo ""
}

uninstall_yabai() {
    print_info "Removing Yabai and skhd configuration..."

    # Stop services if running
    if [ "$OS" = "macos" ]; then
        if command -v yabai >/dev/null 2>&1; then
            print_info "Stopping Yabai..."
            brew services stop yabai 2>/dev/null || true
            killall yabai 2>/dev/null || true
        fi

        if command -v skhd >/dev/null 2>&1; then
            print_info "Stopping skhd..."
            brew services stop skhd 2>/dev/null || true
            killall skhd 2>/dev/null || true
        fi
    fi

    remove_symlink "$HOME/.config/yabai" "~/.config/yabai"
    remove_symlink "$HOME/.config/skhd" "~/.config/skhd"
    echo ""
}

uninstall_hammerspoon() {
    print_info "Removing Hammerspoon dropdown terminal configuration..."

    if [ -f "$HOME/.hammerspoon/init.lua" ]; then
        if grep -q "Dropdown WezTerm Terminal" "$HOME/.hammerspoon/init.lua"; then
            print_warning "Found dropdown config in ~/.hammerspoon/init.lua"
            read -p "Remove entire Hammerspoon config? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm "$HOME/.hammerspoon/init.lua"
                print_success "Removed ~/.hammerspoon/init.lua"
            else
                print_info "Skipped. Manually remove dropdown config from ~/.hammerspoon/init.lua"
            fi
        fi
    else
        print_info "Hammerspoon config not found"
    fi
    echo ""
}

uninstall_hyprland_dropdown() {
    print_info "Removing Hyprland dropdown terminal configuration..."

    remove_symlink "$HOME/.config/hyprland/dropdown.conf" "~/.config/hyprland/dropdown.conf"

    if [ -f "$HOME/.config/hyprland/scripts/toggle_dropdown.sh" ]; then
        rm "$HOME/.config/hyprland/scripts/toggle_dropdown.sh"
        print_success "Removed toggle_dropdown.sh"
    fi

    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
        if grep -q "source.*hyprland/dropdown.conf" "$HOME/.config/hypr/hyprland.conf"; then
            print_warning "Found dropdown source in hyprland.conf"
            print_info "Manually remove: source = ~/.config/hyprland/dropdown.conf"
        fi
    fi
    echo ""
}

# ====== Interactive Menu ======

show_menu() {
    echo ""
    echo "======================================"
    echo "  Dotfiles Uninstallation"
    echo "======================================"
    echo ""
    echo "Select configurations to remove:"
    echo ""
    echo "  1) Zsh configuration (~/.zshrc)"
    echo "  2) WezTerm configuration (~/.wezterm.lua)"
    echo "  3) Starship configuration (~/.config/starship.toml)"
    echo "  4) SketchyBar configuration (~/.config/sketchybar)"
    echo "  5) Yabai + skhd configuration (~/.config/yabai, ~/.config/skhd)"
    echo "  6) Hammerspoon dropdown config (~/.hammerspoon/init.lua)"
    echo "  7) Hyprland dropdown config (~/.config/hyprland/dropdown.conf)"
    echo ""
    echo "  a) Remove all configurations"
    echo "  q) Quit"
    echo ""
}

process_choice() {
    local choice=$1

    case $choice in
        1)
            uninstall_zsh
            ;;
        2)
            uninstall_wezterm
            ;;
        3)
            uninstall_starship
            ;;
        4)
            uninstall_sketchybar
            ;;
        5)
            if [ "$OS" = "macos" ]; then
                uninstall_yabai
            else
                print_warning "Yabai is macOS only"
            fi
            ;;
        6)
            if [ "$OS" = "macos" ]; then
                uninstall_hammerspoon
            else
                print_warning "Hammerspoon is macOS only"
            fi
            ;;
        7)
            if [ "$OS" = "linux" ]; then
                uninstall_hyprland_dropdown
            else
                print_warning "Hyprland is Linux only"
            fi
            ;;
        a|A)
            echo ""
            print_warning "This will remove ALL dotfiles configurations!"
            read -p "Are you sure? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                uninstall_zsh
                uninstall_wezterm
                uninstall_starship
                uninstall_sketchybar
                uninstall_yabai

                if [ "$OS" = "macos" ]; then
                    uninstall_hammerspoon
                elif [ "$OS" = "linux" ]; then
                    uninstall_hyprland_dropdown
                fi

                print_success "All configurations removed"
            else
                print_info "Cancelled"
            fi
            return 1
            ;;
        q|Q)
            print_info "Exiting..."
            return 1
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac

    return 0
}

# ====== Main ======

main() {
    detect_os

    while true; do
        show_menu
        read -p "Enter your choice: " choice

        if ! process_choice "$choice"; then
            break
        fi

        read -p "Press Enter to continue..."
    done

    echo ""
    echo "======================================"
    print_success "Uninstallation completed!"
    echo "======================================"
    echo ""
}

# Run main function
main

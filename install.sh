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
            print_info "Detected: macOS"
            ;;
        Linux*)
            OS="linux"
            print_info "Detected: Linux"

            # Detect Linux distribution
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO=$ID
                print_info "Distribution: $DISTRO"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS="windows"
            print_info "Detected: Windows"
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

# Install Homebrew (macOS)
install_homebrew() {
    if ! command_exists brew; then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        print_success "Homebrew installed"
    else
        print_info "Homebrew already installed"
    fi
}

# Install packages for macOS
install_macos_packages() {
    print_info "Installing macOS packages..."

    install_homebrew

    # Update Homebrew
    brew update

    # Install packages
    local packages=(
        "starship"
        "fzf"
    )

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_info "$package already installed"
        else
            print_info "Installing $package..."
            brew install "$package"
        fi
    done

    # Install cask packages
    local casks=(
        "wezterm"
        "font-fira-code-nerd-font"
    )

    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_info "$cask already installed"
        else
            print_info "Installing $cask..."
            brew install --cask "$cask"
        fi
    done

    print_success "macOS packages installed"
}

# Install packages for Linux
install_linux_packages() {
    print_info "Installing Linux packages..."

    case "$DISTRO" in
        ubuntu|debian)
            sudo apt-get update

            # Install Starship
            if ! command_exists starship; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi

            # Install fzf
            if ! command_exists fzf; then
                sudo apt-get install -y fzf
            fi

            print_success "Ubuntu/Debian packages installed"
            ;;

        fedora|rhel|centos)
            sudo dnf check-update || true

            # Install Starship
            if ! command_exists starship; then
                curl -sS https://starship.rs/install.sh | sh -s -- -y
            fi

            # Install fzf
            if ! command_exists fzf; then
                sudo dnf install -y fzf
            fi

            print_success "Fedora/RHEL packages installed"
            ;;

        arch|manjaro)
            sudo pacman -Sy

            # Install packages
            sudo pacman -S --noconfirm --needed starship fzf

            print_success "Arch packages installed"
            ;;

        *)
            print_warning "Unsupported Linux distribution: $DISTRO"
            print_info "Please install starship and fzf manually"
            print_info "Starship: curl -sS https://starship.rs/install.sh | sh"
            ;;
    esac
}

# ====== Link Configuration Files ======

link_configs() {
    print_info "Linking configuration files..."

    # Common configs (all OS)
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

    # OS-specific configs
    case "$OS" in
        macos)
            create_symlink "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
            ;;
        linux)
            # WezTerm also works on Linux
            if command_exists wezterm; then
                create_symlink "$DOTFILES_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
            fi
            ;;
    esac

    print_success "Configuration files linked"
}

# ====== Dropdown Terminal Setup ======

setup_dropdown_terminal() {
    print_info "Setting up dropdown terminal (optional)..."

    case "$OS" in
        macos)
            echo ""
            read -p "Do you want to set up dropdown terminal (Quake-mode)? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Install Hammerspoon if not installed
                if ! brew list --cask hammerspoon &>/dev/null; then
                    print_info "Installing Hammerspoon for dropdown terminal support..."
                    brew install --cask hammerspoon
                fi

                # Create Hammerspoon config directory
                mkdir -p "$HOME/.hammerspoon"

                # Create or append to Hammerspoon config
                if [ ! -f "$HOME/.hammerspoon/init.lua" ]; then
                    print_info "Creating Hammerspoon configuration..."
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
        -- Launch WezTerm in dropdown mode
        wezterm = hs.application.open(weztermBundleID, 1, true)
        hs.timer.doAfter(0.3, function()
            local win = wezterm:mainWindow()
            if win then
                local screen = hs.screen.mainScreen()
                local frame = screen:frame()
                -- Position: full width, 50% height, top of screen
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
            -- Hide
            wezterm:hide()
        else
            -- Show and focus
            wezterm:activate()
            local win = wezterm:mainWindow()
            if win then
                win:focus()
            end
        end
    end
end)

-- Auto-reload config on changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
    hs.reload()
end):start()

hs.alert.show("Hammerspoon Config Loaded")
EOF
                    print_success "Hammerspoon config created at ~/.hammerspoon/init.lua"
                else
                    print_info "Hammerspoon config already exists at ~/.hammerspoon/init.lua"
                    print_info "Add dropdown terminal config from: $DOTFILES_DIR/docs/DROPDOWN_TERMINAL.md"
                fi

                # Open Hammerspoon
                print_info "Opening Hammerspoon..."
                open -a Hammerspoon

                echo ""
                print_success "Dropdown terminal setup completed!"
                print_info "Hotkey: Cmd+Shift+Space"
                print_info "Full documentation: $DOTFILES_DIR/docs/DROPDOWN_TERMINAL.md"
            else
                print_info "Skipping dropdown terminal setup"
                print_info "You can set it up later using: $DOTFILES_DIR/docs/DROPDOWN_TERMINAL.md"
            fi
            ;;

        linux)
            echo ""
            print_info "Dropdown terminal can be configured for your window manager"

            # Detect window manager
            if [ ! -z "$XDG_CURRENT_DESKTOP" ]; then
                print_info "Detected desktop: $XDG_CURRENT_DESKTOP"
            fi

            # Check for Hyprland
            if command_exists hyprctl || [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
                print_info "Hyprland detected!"
                echo ""
                read -p "Do you want to set up dropdown terminal for Hyprland? [y/N] " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    # Create Hyprland config directory
                    mkdir -p "$HOME/.config/hyprland/scripts"

                    # Copy dropdown config
                    if [ ! -f "$HOME/.config/hyprland/dropdown.conf" ]; then
                        create_symlink "$DOTFILES_DIR/.config/hyprland/dropdown.conf" "$HOME/.config/hyprland/dropdown.conf"
                        print_success "Created Hyprland dropdown config"
                    else
                        print_info "Hyprland dropdown config already exists"
                    fi

                    # Copy toggle script
                    if [ ! -f "$HOME/.config/hyprland/scripts/toggle_dropdown.sh" ]; then
                        cp "$DOTFILES_DIR/scripts/toggle_dropdown_hyprland.sh" "$HOME/.config/hyprland/scripts/toggle_dropdown.sh"
                        chmod +x "$HOME/.config/hyprland/scripts/toggle_dropdown.sh"
                        print_success "Created toggle script"
                    fi

                    # Check if source line exists in hyprland.conf
                    if [ -f "$HOME/.config/hypr/hyprland.conf" ]; then
                        if ! grep -q "source.*hyprland/dropdown.conf" "$HOME/.config/hypr/hyprland.conf"; then
                            echo "" >> "$HOME/.config/hypr/hyprland.conf"
                            echo "# Dropdown terminal configuration" >> "$HOME/.config/hypr/hyprland.conf"
                            echo "source = ~/.config/hyprland/dropdown.conf" >> "$HOME/.config/hypr/hyprland.conf"
                            print_success "Added dropdown config to hyprland.conf"
                        else
                            print_info "Dropdown config already sourced in hyprland.conf"
                        fi

                        # Reload Hyprland config
                        print_info "Reloading Hyprland config..."
                        hyprctl reload 2>/dev/null || print_warning "Could not reload Hyprland (not running?)"
                    else
                        print_warning "hyprland.conf not found at ~/.config/hypr/hyprland.conf"
                        print_info "Add this line to your config: source = ~/.config/hyprland/dropdown.conf"
                    fi

                    echo ""
                    print_success "Hyprland dropdown terminal setup completed!"
                    print_info 'Hotkey: Super+` (grave key)'
                    print_info "Full documentation: $DOTFILES_DIR/docs/DROPDOWN_TERMINAL.md"
                else
                    print_info "Skipping Hyprland dropdown setup"
                fi

            # Check for i3
            elif command_exists i3; then
                print_info "i3 detected. Add to ~/.config/i3/config:"
                echo "  bindsym \$mod+grave exec wezterm start --class dropdown"
                echo "  for_window [class=\"dropdown\"] floating enable, resize set 100ppt 50ppt, move position 0 0"

            # Check for Sway
            elif command_exists sway; then
                print_info "Sway detected. Add to ~/.config/sway/config:"
                echo "  bindsym \$mod+grave exec wezterm start --class dropdown"
                echo "  for_window [app_id=\"dropdown\"] floating enable, resize set 100ppt 50ppt, move position 0 0"

            # Other WMs
            else
                print_info "For other window managers, see: $DOTFILES_DIR/docs/DROPDOWN_TERMINAL.md"
            fi
            ;;
    esac

    echo ""
}

# ====== Post-installation ======

post_install() {
    print_info "Running post-installation steps..."

    # Setup fzf if installed
    if command_exists fzf; then
        case "$OS" in
            macos)
                if [ -f /opt/homebrew/opt/fzf/install ]; then
                    /opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc
                elif [ -f /usr/local/opt/fzf/install ]; then
                    /usr/local/opt/fzf/install --key-bindings --completion --no-update-rc
                fi
                ;;
            linux)
                if [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
                    echo "source /usr/share/doc/fzf/examples/key-bindings.zsh" >> ~/.zshrc.local
                fi
                ;;
        esac
    fi

    # Change default shell to zsh if not already
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

    print_success "Post-installation completed"
}

# ====== Main ======

main() {
    echo ""
    echo "======================================"
    echo "  Dotfiles Installation"
    echo "======================================"
    echo ""

    detect_os

    # Install packages based on OS
    case "$OS" in
        macos)
            install_macos_packages
            ;;
        linux)
            install_linux_packages
            ;;
        windows)
            print_warning "Windows detected. Limited support."
            print_info "Please install required tools manually:"
            print_info "  - Starship: https://starship.rs/"
            print_info "  - WezTerm: https://wezfurlong.org/wezterm/"
            ;;
    esac

    # Link configs
    link_configs

    # Post-installation
    post_install

    # Setup dropdown terminal (optional)
    if command_exists wezterm || [ "$OS" = "macos" ]; then
        setup_dropdown_terminal
    fi

    echo ""
    echo "======================================"
    print_success "Installation completed!"
    echo "======================================"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. If using WezTerm, restart it to apply configs"

    if [ "$OS" = "macos" ]; then
        echo "  3. For dropdown terminal: Press Cmd+Shift+Space"
    fi

    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        print_info "Backups saved to: $BACKUP_DIR"
    fi

    echo ""
}

# Run main function
main

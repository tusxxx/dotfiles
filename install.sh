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

    echo ""
    echo "======================================"
    print_success "Installation completed!"
    echo "======================================"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. If using WezTerm, restart it to apply configs"

    if [ -d "$BACKUP_DIR" ]; then
        echo ""
        print_info "Backups saved to: $BACKUP_DIR"
    fi

    echo ""
}

# Run main function
main

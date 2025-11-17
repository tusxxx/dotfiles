# Dotfiles

Personal configuration files for macOS and Linux development environments.

## Contents

- **[.zshrc](#zsh)** - Zsh shell configuration
- **[.config/starship.toml](#starship)** - Starship prompt configuration
- **[.wezterm.lua](#wezterm)** - WezTerm terminal emulator configuration

## Supported OS

- **macOS** - Full support with Homebrew
- **Linux** - Ubuntu, Debian, Fedora, RHEL, Arch, Manjaro
- **Windows** - Limited support (manual installation required)

## Requirements

### macOS
- [Homebrew](https://brew.sh/)
- Zsh (default shell on macOS)

### Linux
- Zsh
- Package manager (apt, dnf, or pacman)

### All Platforms
- [Starship](https://starship.rs/) - Cross-platform prompt
- [WezTerm](https://wezfurlong.org/wezterm/) - Terminal emulator (optional)
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder (optional)
- Nerd Font for icons - e.g., [FiraCode Nerd Font](https://www.nerdfonts.com/) (optional)

## Installation

### Automated Installation (Recommended)

The install script automatically detects your OS and installs everything:

```bash
# Clone repository
git clone https://github.com/tusxxx/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run installation script
./install.sh
```

**What it does:**
- Detects your OS (macOS, Linux distro, or Windows)
- Installs required packages (Starship, fzf, WezTerm, Nerd Font)
- Creates backups of existing configs
- Creates symlinks to dotfiles
- Sets up fzf key bindings
- Changes default shell to zsh (if needed)

### Manual Installation

If you prefer manual setup or want to install specific configs only:

```bash
# Clone repository
git clone https://github.com/tusxxx/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install required tools manually
# macOS:
brew install starship fzf
brew install --cask wezterm font-fira-code-nerd-font

# Ubuntu/Debian:
curl -sS https://starship.rs/install.sh | sh
sudo apt-get install fzf

# Create symlinks
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.wezterm.lua ~/.wezterm.lua
mkdir -p ~/.config
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml

# Reload shell
source ~/.zshrc
```

## Configuration Details

### Zsh

`.zshrc` includes:

- **History**: 10,000 commands with deduplication
- **Completion**: Smart case-insensitive completion with menu
- **Aliases**:
  - Navigation: `..`, `...`, `....`
  - Git shortcuts: `gs`, `ga`, `gc`, `gp`, `gl`, etc.
  - List: `ll`, `la`
  - MacOS specific: `showfiles`, `hidefiles`, `cleanup`
- **Functions**:
  - `mkcd` - create and enter directory
  - `extract` - universal archive extractor
- **Starship integration**

### Starship

`.config/starship.toml` features:

- **Two-line prompt** with box drawing characters
- **Git integration**: branch, status, commit info
- **Language indicators**: Node.js, Python, Rust, Go, Java
- **Docker context** display
- **Command duration** for slow commands (>500ms)
- **Custom icons** for directories and tools
- **Color-coded status** indicators

### WezTerm

`.wezterm.lua` provides terminal emulator configuration.

## Customization

### Local Overrides

For machine-specific settings, create `~/.zshrc.local`:

```bash
# Example: ~/.zshrc.local
export CUSTOM_VAR="value"
alias custom_alias="command"
```

This file is sourced automatically and not tracked in git.

## Updating

```bash
cd ~/dotfiles
git pull origin main
source ~/.zshrc  # reload shell config
```

## Structure

```
dotfiles/
├── .config/
│   └── starship.toml    # Starship prompt config
├── .wezterm.lua         # WezTerm terminal config
├── .zshrc               # Zsh shell config
├── install.sh           # Automated installation script
├── CLAUDE.md            # Claude AI project guidelines
└── README.md            # This file
```

## Tips

### Enable Starship

Make sure Starship is initialized in your `.zshrc`:

```bash
eval "$(starship init zsh)"
```

### Font Setup

For proper icon display, install a Nerd Font:

```bash
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font
```

Then set it in WezTerm config.

### Git Config

Don't forget to set your global git configuration:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Troubleshooting

**Icons not displaying?**
- Install a Nerd Font
- Set the font in your terminal emulator

**Starship not loading?**
- Check if installed: `starship --version`
- Verify init command in `.zshrc`

**Permission issues?**
- Ensure files are readable: `chmod 644 ~/dotfiles/.zshrc`

## License

MIT

## Author

tusxxx

#!/usr/bin/env bash
# ==============================================================================
# Debian Dotfiles Setup Script
# Restores the XFCE + i3 + Picom + Alacritty desktop setup on Debian.
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

info()  { echo -e "\e[34m[INFO]\e[0m $*"; }
ok()    { echo -e "\e[32m[OK]\e[0m $*"; }
warn()  { echo -e "\e[33m[WARN]\e[0m $*"; }
error() { echo -e "\e[31m[ERROR]\e[0m $*"; }

INSTALL_PKGS=true
AUTO_YES=false

for arg in "$@"; do
    case "$arg" in
        --no-pkgs) INSTALL_PKGS=false ;;
        -y|--yes)  AUTO_YES=true ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --no-pkgs    Skip apt package installation"
            echo "  -y, --yes    Automatic yes to prompts"
            exit 0
            ;;
    esac
done

# ------------------------------------------------------------------------------
# 1. Package Installation
# ------------------------------------------------------------------------------
if [ "$INSTALL_PKGS" = true ]; then
    if command -v apt >/dev/null 2>&1; then
        info "Installing Debian packages from packages-debian.txt..."
        if [ "$AUTO_YES" = true ]; then
            sudo apt update && sudo apt install -y $(grep -v '^#' "$DOTFILES_DIR/packages-debian.txt" | tr '\n' ' ')
        else
            read -rp "Install Debian packages using apt? [Y/n] " response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY]|"")$ ]]; then
                sudo apt update && sudo apt install -y $(grep -v '^#' "$DOTFILES_DIR/packages-debian.txt" | tr '\n' ' ')
            else
                info "Skipping apt package installation."
            fi
        fi
    else
        warn "apt not found; skipping package installation."
    fi
fi

# ------------------------------------------------------------------------------
# 2. Backup Existing Configs
# ------------------------------------------------------------------------------
backup_item() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        # If it's already a symlink pointing into DOTFILES_DIR, skip backing up
        if [ -L "$target" ] && [[ "$(readlink -f "$target")" == "$DOTFILES_DIR"* ]]; then
            return
        fi
        mkdir -p "$BACKUP_DIR"
        info "Backing up $(basename "$target") to $BACKUP_DIR/"
        mv "$target" "$BACKUP_DIR/"
    fi
}

mkdir -p "$HOME/.config" "$HOME/.local/share/fonts" "$HOME/.icons" "$HOME/Downloads"

# ------------------------------------------------------------------------------
# 3. Symlink / Deploy Dotfiles
# ------------------------------------------------------------------------------
info "Deploying dotfiles..."

# Top-level dotfiles
for file in .bashrc .vimrc .gitconfig .fehbg; do
    if [ -f "$DOTFILES_DIR/$file" ]; then
        backup_item "$HOME/$file"
        ln -snf "$DOTFILES_DIR/$file" "$HOME/$file"
        ok "Linked $file -> ~/$file"
    fi
done

chmod +x "$HOME/.fehbg" 2>/dev/null || true

# ~/.config subdirectories
for item in "$DOTFILES_DIR/.config"/*; do
    target_name="$(basename "$item")"
    target_dest="$HOME/.config/$target_name"
    backup_item "$target_dest"
    ln -snf "$item" "$target_dest"
    ok "Linked .config/$target_name -> ~/.config/$target_name"
done

# ------------------------------------------------------------------------------
# 4. Wallpaper & Assets
# ------------------------------------------------------------------------------
if [ -f "$DOTFILES_DIR/assets/wallpaper.png" ]; then
    info "Setting up wallpaper..."
    mkdir -p "$HOME/Downloads"
    # Ensure wallpaper exists at ~/Downloads/wallpaper.png (referenced by i3 and xfce4-panel)
    if [ ! -f "$HOME/Downloads/wallpaper.png" ]; then
        cp "$DOTFILES_DIR/assets/wallpaper.png" "$HOME/Downloads/wallpaper.png"
    fi
    mkdir -p "$HOME/.config"
    ln -snf "$DOTFILES_DIR/assets/wallpaper.png" "$HOME/.config/wallpaper.png"
    ok "Wallpaper placed at ~/Downloads/wallpaper.png and ~/.config/wallpaper.png"
fi

# ------------------------------------------------------------------------------
# 5. Icon Theme (YAMIS)
# ------------------------------------------------------------------------------
if [ -f "$DOTFILES_DIR/assets/icons/yet-another-monochrome-icon-set.tar.gz" ]; then
    if [ ! -d "$HOME/.icons/YAMIS" ]; then
        info "Extracting YAMIS icon theme..."
        mkdir -p "$HOME/.icons"
        tar -xzf "$DOTFILES_DIR/assets/icons/yet-another-monochrome-icon-set.tar.gz" -C "$HOME/.icons/"
        ok "YAMIS icon theme installed in ~/.icons/YAMIS"
    else
        ok "YAMIS icon theme already present in ~/.icons/YAMIS"
    fi
fi

# ------------------------------------------------------------------------------
# 6. JetBrainsMono Nerd Font
# ------------------------------------------------------------------------------
if ! fc-list : family | grep -qi "JetBrainsMono Nerd Font"; then
    info "Installing JetBrainsMono Nerd Font..."
    FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
    mkdir -p "$FONT_DIR"
    curl -fLo /tmp/JetBrainsMono.tar.xz "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    tar -xf /tmp/JetBrainsMono.tar.xz -C "$FONT_DIR"
    rm -f /tmp/JetBrainsMono.tar.xz
    fc-cache -fv "$HOME/.local/share/fonts"
    ok "JetBrainsMono Nerd Font installed and font cache updated."
else
    ok "JetBrainsMono Nerd Font already installed."
fi

# ------------------------------------------------------------------------------
# 7. Alacritty Themes Repo (Optional extra themes)
# ------------------------------------------------------------------------------
if [ ! -d "$HOME/.config/alacritty/themes/themes" ] || [ ! -f "$HOME/.config/alacritty/themes/themes/Cobalt2.toml" ]; then
    mkdir -p "$HOME/.config/alacritty/themes"
    cp -r "$DOTFILES_DIR/.config/alacritty/themes"/* "$HOME/.config/alacritty/themes/" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 8. Autotiling check
# ------------------------------------------------------------------------------
if ! command -v autotiling >/dev/null 2>&1; then
    warn "autotiling command not found. You can install it via 'sudo apt install autotiling' or 'pip install autotiling'."
fi

ok "Debian setup complete!"
echo
echo "To activate your desktop:"
echo "1. Log into your XFCE session (xfce4-session will automatically start i3 as configured)."
echo "2. Enjoy your custom XFCE + i3 + Picom + Alacritty environment!"

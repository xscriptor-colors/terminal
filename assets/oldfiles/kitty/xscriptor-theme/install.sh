#!/bin/bash

# Xscriptor Theme installation script for Kitty Terminal
# Author: Xscriptor
# Description: Installs Xscriptor theme based on VSCode Xscriptor theme color palette

set -e

echo "Installing Xscriptor theme for Kitty Terminal..."

# Verificar si Kitty está instalado
if ! command -v kitty &> /dev/null; then
    echo "Error: Kitty Terminal is not installed."
    echo "To install Kitty:"
    echo "   Ubuntu/Debian: sudo apt install kitty"
    echo "   Fedora: sudo dnf install kitty"
    echo "   Arch: sudo pacman -S kitty"
    echo "   X Linux: sudo xpm -S kitty"
    echo "   macOS: brew install kitty"
    echo "   Or visit: https://sw.kovidgoyal.net/kitty/binary/"
    exit 1
fi

# Determinar directorio de configuración de Kitty
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    KITTY_CONFIG_DIR="$HOME/.config/kitty"
else
    # Linux y otros Unix
    KITTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
fi

echo "Configuration directory: $KITTY_CONFIG_DIR"

# Crear directorio de configuración si no existe
if [ ! -d "$KITTY_CONFIG_DIR" ]; then
    echo "Creating configuration directory..."
    mkdir -p "$KITTY_CONFIG_DIR"
fi

# Verificar si el archivo de tema existe en el directorio actual
THEME_FILE="xscriptor-theme-kitty.conf"
if [ ! -f "$THEME_FILE" ]; then
    echo "Error: $THEME_FILE file not found in current directory."
    echo "Make sure to run this script from the directory containing $THEME_FILE"
    exit 1
fi

# Copiar archivo de tema
echo "Copying theme file..."
cp "$THEME_FILE" "$KITTY_CONFIG_DIR/"

# Verificar si ya existe un kitty.conf
KITTY_CONF="$KITTY_CONFIG_DIR/kitty.conf"
BACKUP_CONF="$KITTY_CONFIG_DIR/kitty.conf.backup.$(date +%Y%m%d_%H%M%S)"

if [ -f "$KITTY_CONF" ]; then
    echo "Found existing Kitty configuration."
    read -p "Do you want to create a backup and apply the theme? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating backup at: $BACKUP_CONF"
        cp "$KITTY_CONF" "$BACKUP_CONF"
        
        # Verificar si ya hay una inclusión del tema
        if grep -q "include.*x-theme-kitty.conf" "$KITTY_CONF"; then
            echo "Theme is already included in configuration."
        else
            echo "Adding theme inclusion to kitty.conf..."
            echo "" >> "$KITTY_CONF"
            echo "# Xscriptor Theme" >> "$KITTY_CONF"
            echo "include x-theme-kitty.conf" >> "$KITTY_CONF"
        fi
    else
        echo "Installation cancelled. Theme file was copied but not applied."
        echo "To apply manually, add this line to your kitty.conf:"
        echo "   include x-theme-kitty.conf"
        exit 0
    fi
else
    echo "Creating new Kitty configuration..."
    cat > "$KITTY_CONF" << EOF
# Kitty configuration with Xscriptor theme

# Include Xscriptor theme
include x-theme-kitty.conf

# Additional configurations (customize as needed)
# font_family JetBrains Mono
# font_size 10
# enable_audio_bell no
# window_padding_width 4
EOF
fi

echo "Xscriptor theme installed successfully for Kitty!"
echo "To apply changes:"
echo "   1. Restart Kitty Terminal"
echo "   2. Or press Ctrl+Shift+F5 to reload configuration"
echo
echo "Installed files:"
echo "   - Theme: $KITTY_CONFIG_DIR/$THEME_FILE"
echo "   - Configuration: $KITTY_CONF"
if [ -f "$BACKUP_CONF" ]; then
    echo "   - Backup: $BACKUP_CONF"
fi
echo
echo "Tips:"
echo "   - To customize more options, edit: $KITTY_CONF"
echo "   - Kitty documentation: https://sw.kovidgoyal.net/kitty/conf/"
echo "   - To uninstall, remove the 'include x-theme-kitty.conf' line from kitty.conf"
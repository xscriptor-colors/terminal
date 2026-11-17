#!/bin/bash

# Xscriptor Theme installation script for GNOME Terminal
# Author: Xscriptor
# Description: Installs Xscriptor theme based on VSCode Xscriptor theme color palette

set -e

echo "Installing Xscriptor theme for GNOME Terminal..."

# Check if dconf is available
if ! command -v dconf &> /dev/null; then
    echo "Error: dconf is not installed. Please install it first:"
    echo "   Ubuntu/Debian: sudo apt install dconf-cli"
    echo "   Fedora: sudo dnf install dconf"
    echo "   Arch: sudo pacman -S dconf"
    echo "   X Linux: sudo xpm -S dconf"
    exit 1
fi

# Check if GNOME Terminal is installed
if ! command -v gnome-terminal &> /dev/null; then
    echo "Error: GNOME Terminal is not installed."
    exit 1
fi

# Ask if user wants transparency
read -p "Do you want to enable transparency? (y/N): " -n 1 -r
echo
USE_TRANSPARENCY=false
if [[ $REPLY =~ ^[Yy]$ ]]; then
    USE_TRANSPARENCY=true

    # On Arch-based/X Linux systems, check/install gnome-terminal-transparency
    if command -v xpm &> /dev/null; then
        PM=xpm
    elif command -v pacman &> /dev/null; then
        PM=pacman
    fi
    if [ -n "${PM:-}" ]; then
        echo "Arch-based system detected (using $PM)."
        if ! $PM -Qi gnome-terminal-transparency &> /dev/null; then
            echo "Package gnome-terminal-transparency is not installed."
            read -p "Do you want to install gnome-terminal-transparency from AUR? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if command -v yay &> /dev/null; then
                    yay -S --noconfirm gnome-terminal-transparency
                else
                    echo "Error: yay is not installed. Please install it first with:"
                    echo "   sudo $PM -S --needed base-devel git"
                    echo "   git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
                    exit 1
                fi
            else
                echo "Transparency installation skipped by user."
                USE_TRANSPARENCY=false
            fi
        else
            echo "gnome-terminal-transparency is already installed."
        fi
    fi
fi

# Function to check if a UUID already exists
check_uuid_exists() {
    local uuid=$1
    dconf list /org/gnome/terminal/legacy/profiles:/ | grep -q ":$uuid/" 2>/dev/null
}

# Generate unique UUID for the new profile
echo "Generating unique UUID for profile..."
PROFILE_UUID=$(uuidgen)

while check_uuid_exists "$PROFILE_UUID"; do
    echo "UUID $PROFILE_UUID already exists, generating a new one..."
    PROFILE_UUID=$(uuidgen)
done

PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:$PROFILE_UUID/"

echo "Creating profile with UUID: $PROFILE_UUID"

# Get current profile list
CURRENT_PROFILES=$(dconf read /org/gnome/terminal/legacy/profiles:/list | tr -d "[]'" | tr ',' '\n' | grep -v '^$' || true)

if [ -z "$CURRENT_PROFILES" ]; then
    NEW_PROFILES="['$PROFILE_UUID']"
else
    PROFILE_LIST=$(echo "$CURRENT_PROFILES" | sed "s/^/'/ ; s/$/',/" | tr -d '\n' | sed 's/,$//')
    NEW_PROFILES="[$PROFILE_LIST,'$PROFILE_UUID']"
fi

# Apply theme configuration
echo "Applying theme configuration..."

dconf write /org/gnome/terminal/legacy/profiles:/list "$NEW_PROFILES"
dconf write "${PROFILE_PATH}visible-name" "'Xscriptor Theme'"
dconf write "${PROFILE_PATH}palette" "['#363537', '#fc618d', '#7bd88f', '#fce566', '#fd9353', '#948ae3', '#5ad4e6', '#f7f1ff', '#69676c', '#fc618d', '#7bd88f', '#fce566', '#fd9353', '#948ae3', '#5ad4e6', '#f7f1ff']"
dconf write "${PROFILE_PATH}background-color" "'#050505'"
dconf write "${PROFILE_PATH}foreground-color" "'#f7f1ff'"
dconf write "${PROFILE_PATH}use-theme-colors" "false"
dconf write "${PROFILE_PATH}bold-color-same-as-fg" "true"
dconf write "${PROFILE_PATH}bold-color" "'#f7f1ff'"
dconf write "${PROFILE_PATH}cursor-colors-set" "true"
dconf write "${PROFILE_PATH}cursor-background-color" "'#f7f1ff'"
dconf write "${PROFILE_PATH}cursor-foreground-color" "'#050505'"
dconf write "${PROFILE_PATH}highlight-colors-set" "true"
dconf write "${PROFILE_PATH}highlight-background-color" "'#bab6c026'"
dconf write "${PROFILE_PATH}highlight-foreground-color" "'#f7f1ff'"

# Apply transparency settings
if [ "$USE_TRANSPARENCY" = true ]; then
    echo "Applying transparency settings..."
    dconf write "${PROFILE_PATH}use-theme-transparency" "true"
    dconf write "${PROFILE_PATH}use-transparent-background" "true"
    dconf write "${PROFILE_PATH}background-transparency-percent" "40"
else
    echo "Transparency disabled, using solid background."
    dconf write "${PROFILE_PATH}use-theme-transparency" "false"
    dconf write "${PROFILE_PATH}use-transparent-background" "false"
    dconf write "${PROFILE_PATH}background-transparency-percent" "0"
fi

# Optionally set as default profile
read -p "Do you want to set Xscriptor theme as the default profile? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    dconf write /org/gnome/terminal/legacy/profiles:/default "'$PROFILE_UUID'"
    echo "Xscriptor Theme set as default profile"
fi

echo "Xscriptor Theme installed successfully!"
echo "To use the theme:"
echo "   1. Open GNOME Terminal"
echo "   2. Go to Preferences > Profiles"
echo "   3. Select 'Xscriptor Theme'"
echo "   4. Enjoy your new theme!"
echo
echo "Tip: You can also launch a new window with the theme using:"
echo "   gnome-terminal --profile='Xscriptor Theme'"

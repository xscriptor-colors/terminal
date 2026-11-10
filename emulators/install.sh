#!/usr/bin/env bash

set -euo pipefail

echo "=============================================="
echo " Terminal Xscriptor - Universal Theme Installer "
echo "=============================================="
echo ""
echo "Select the terminal you want to install themes for:"
echo "1) Alacritty"
echo "2) Foot"
echo "3) Ghostty"
echo "4) GNOME Terminal"
echo "5) Hyper"
echo "6) iTerm2"
echo "7) Kitty"
echo "8) Konsole"
echo "9) Ptyxis"
echo "10) Terminator"
echo "11) Termux"
echo "12) Warp"
echo "13) WezTerm"
echo "14) XFCE Terminal"
echo "15) Exit"
echo ""

read -p "Enter your choice (1-15): " choice

url_base="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators"

fetch() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- "$1"
    else
        echo "Error: curl or wget is required." >&2
        exit 1
    fi
}

install_remote() {
    fetch "$url_base/$1/install.sh" | bash
}

case $choice in
    1)
        echo "Installing Alacritty themes..."
        install_remote alacritty
        ;;
    2)
        echo "Installing Foot themes..."
        install_remote foot
        ;;
    3)
        echo "Installing Ghostty themes..."
        install_remote ghostty
        ;;
    4)
        echo "Installing GNOME Terminal themes..."
        install_remote gnome-terminal
        ;;
    5)
        echo "Installing Hyper themes..."
        install_remote hyper
        ;;
    6)
        echo "Installing iTerm2 themes..."
        install_remote iterm
        ;;
    7)
        echo "Installing Kitty themes..."
        install_remote kitty
        ;;
    8)
        echo "Installing Konsole themes..."
        install_remote konsole
        ;;
    9)
        echo "Installing Ptyxis themes..."
        install_remote ptyxis
        ;;
    10)
        echo "Installing Terminator themes..."
        install_remote terminator
        ;;
    11)
        echo "Installing Termux themes..."
        install_remote termux
        ;;
    12)
        echo "Installing Warp themes..."
        install_remote warp
        ;;
    13)
        echo "Installing WezTerm themes..."
        install_remote wezterm
        ;;
    14)
        echo "Installing XFCE Terminal themes..."
        install_remote xfce
        ;;
    15)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

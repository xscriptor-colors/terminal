#!/usr/bin/env sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_THEMES_DIR="$SCRIPT_DIR/themes"
TARGET_CONFIG_DIR="$HOME/.config/foot"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/themes"
MAIN="$TARGET_CONFIG_DIR/foot.ini"

detect_pm() {
  for pm in apt-get dnf xpm pacman zypper yum apk brew; do
    command -v "$pm" >/dev/null 2>&1 && { echo "$pm"; return 0; }
  done
  return 1
}

sudo_cmd() {
  if [ "$(id -u)" -eq 0 ]; then
    echo ""
  elif command -v sudo >/dev/null 2>&1; then
    echo "sudo"
  elif command -v doas >/dev/null 2>&1; then
    echo "doas"
  else
    echo ""
  fi
}

fetch_cmd() {
  if command -v curl >/dev/null 2>&1; then
    echo "curl"
  elif command -v wget >/dev/null 2>&1; then
    echo "wget"
  else
    echo ""
  fi
}

fetch_file() {
  URL="$1"
  DEST="$2"
  CMD="$(fetch_cmd)"
  [ -z "$CMD" ] && return 1
  if [ "$CMD" = "curl" ]; then
    curl -fsSL -o "$DEST" "$URL"
  else
    wget -qO "$DEST" "$URL"
  fi
}
install_pkgs() {
  PM="$(detect_pm)" || { echo "No supported package manager found"; return 1; }
  SUDO="$(sudo_cmd)"
  echo "Using package manager: $PM"
  case "$PM" in
    brew)
      brew update
      for pkg in "$@"; do
        case "$pkg" in
          foot)
            brew install foot
            ;;
          fontconfig|curl|wget|sed|unzip)
            brew install "$pkg"
            ;;
          *)
            brew install "$pkg"
            ;;
        esac
      done
      ;;
    apt-get)
      $SUDO apt-get update
      $SUDO apt-get install -y "$@"
      ;;
    dnf)
      $SUDO dnf install -y "$@"
      ;;
    xpm|pacman)
      $SUDO "$PM" -S --needed --noconfirm "$@"
      ;;
    zypper)
      $SUDO zypper refresh
      $SUDO zypper install -y "$@"
      ;;
    yum)
      $SUDO yum install -y "$@"
      ;;
    apk)
      $SUDO apk update
      $SUDO apk add "$@"
      ;;
    *)
      return 1
      ;;
  esac
}

ensure_unzip() {
  command -v unzip >/dev/null 2>&1 && { echo "unzip is already installed"; return 0; }
  PM="$(detect_pm)" || { echo "No supported package manager found to install unzip"; return 1; }
  SUDO="$(sudo_cmd)"
  echo "Installing unzip with $PM..."
  case "$PM" in
    brew)
      brew install unzip || true
      ;;
    apt-get)
      $SUDO apt-get update
      $SUDO apt-get install -y unzip || true
      ;;
    dnf)
      $SUDO dnf install -y unzip || true
      ;;
    xpm|pacman)
      $SUDO "$PM" -S --needed --noconfirm unzip || true
      ;;
    zypper)
      $SUDO zypper refresh
      $SUDO zypper install -y unzip || true
      ;;
    yum)
      $SUDO yum install -y unzip || true
      ;;
    apk)
      $SUDO apk update
      $SUDO apk add unzip || true
      ;;
    *)
      echo "Could not install unzip automatically"
      ;;
  esac
}

ensure_unzip || true

MISSING=""
command -v foot >/dev/null 2>&1 || MISSING="$MISSING foot"
command -v sed >/dev/null 2>&1 || MISSING="$MISSING sed"
command -v fc-list >/dev/null 2>&1 || MISSING="$MISSING fontconfig"
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  MISSING="$MISSING curl"
fi
command -v unzip >/dev/null 2>&1 || MISSING="$MISSING unzip"

if [ -n "$MISSING" ]; then
  echo "Installing missing packages:$MISSING"
  install_pkgs $MISSING || { echo "Error installing required packages:$MISSING"; exit 1; }
fi

font_installed() {
  command -v fc-list >/dev/null 2>&1 || return 1
  fc-list : family | grep -Ei '\bhack\b.*nerd' >/dev/null 2>&1
}

install_font_macos() {
  echo "Installing Hack Nerd Font on macOS..."
  brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
  brew install --cask font-hack-nerd-font
}

install_font_linux() {
  DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts/Hack"
  mkdir -p "$DEST"
  TTF="$DEST/HackNerdFont-Regular.ttf"
  RAW1="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/assets/fonts/HackNerdFont/HackNerdFont-Regular.ttf"
  RAW2="https://github.com/xscriptor-colors/terminal/raw/main/assets/fonts/HackNerdFont/HackNerdFont-Regular.ttf"
  echo "Downloading Hack Nerd Font (Regular) to: $TTF"
  rm -f "$TTF" 2>/dev/null || true
  fetch_file "$RAW1" "$TTF" || true
  if [ ! -s "$TTF" ]; then
    echo "Primary download failed or empty, trying alternate URL..."
    fetch_file "$RAW2" "$TTF" || true
  fi
  if [ -s "$TTF" ]; then
    echo "Font file downloaded: $TTF"
  else
    echo "Font file not downloaded (empty file)."
  fi
  COUNT="$(ls -1 "$DEST" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Installed font files: $COUNT in $DEST"
  echo "Updating font cache..."
  fc-cache -f "$DEST" >/dev/null 2>&1 || true
  echo "Font cache updated"
}


echo "Checking Hack Nerd Font..."
if font_installed; then
  echo "Font already installed and detected by fontconfig"
else
  OS="$(uname -s)"
  echo "Font not detected, installing on $OS..."
  case "$OS" in
    Darwin)
      install_font_macos
      ;;
    *)
      install_font_linux
      ;;
  esac
  if font_installed; then
    echo "Font installed successfully"
  else
    echo "Warning: font not detected after installation. Check $HOME/.local/share/fonts or the system font manager."
  fi
fi

RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/foot"
THEMES_FILES="x madrid lahabana miami paris tokio oslo helsinki berlin london praha bogota"

mkdir -p "$TARGET_CONFIG_DIR"
mkdir -p "$TARGET_THEMES_DIR"

USE_REMOTE=0
if [ ! -d "$SRC_THEMES_DIR" ] || [ -z "$(ls -1 "$SRC_THEMES_DIR"/*.ini 2>/dev/null)" ] || [ ! -f "$SCRIPT_DIR/foot.ini" ]; then
  USE_REMOTE=1
fi

if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local themes in $SRC_THEMES_DIR"
  for name in $THEMES_FILES; do
    if [ "$name" = "x" ]; then
      src="x.ini"
    else
      src="${name}.ini"
    fi
    if [ -f "$SRC_THEMES_DIR/$src" ]; then
      cp -f "$SRC_THEMES_DIR/$src" "$TARGET_THEMES_DIR/${name}.ini"
    else
      echo "Warning: local source theme not found: $SRC_THEMES_DIR/$src"
    fi
  done
  COUNT_T="$(ls -1 "$TARGET_THEMES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Themes installed: $COUNT_T in $TARGET_THEMES_DIR"
else
  echo "Downloading themes from remote repository..."
  for name in $THEMES_FILES; do
    if [ "$name" = "x" ]; then
      src="x.ini"
    else
      src="${name}.ini"
    fi
    fetch_file "$RAW_BASE/themes/$src" "$TARGET_THEMES_DIR/${name}.ini"
  done
  COUNT_T="$(ls -1 "$TARGET_THEMES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Themes installed (remote): $COUNT_T in $TARGET_THEMES_DIR"
fi

if [ -f "$MAIN" ]; then
  TS="$(date +%s)"
  cp "$MAIN" "$MAIN.bak.$TS"
  echo "Backup created: $MAIN.bak.$TS"
fi
if [ "$USE_REMOTE" -eq 0 ]; then
  cp -f "$SCRIPT_DIR/foot.ini" "$MAIN"
else
  fetch_file "$RAW_BASE/foot.ini" "$MAIN"
fi
echo "Configuration file written: $MAIN"

sed -i -E 's#^include=.*#include=~/.config/foot/themes/x.ini#' "$MAIN" || true
grep -q '^include=' "$MAIN" || {
  if grep -q '^\[main\]' "$MAIN"; then
    sed -i '/^\[main\]/a include=~\/.config\/foot\/themes\/x.ini' "$MAIN"
  else
    {
      echo "[main]"
      echo "include=~/.config/foot/themes/x.ini"
    } >> "$MAIN"
  fi
}
echo "Default theme set: themes/x.ini"

append_aliases() {
  RC="$1"
  [ -f "$RC" ] || touch "$RC"
  sed -i '/^footx() {/,/^}/d' "$RC" || true
  sed -i -E '/^alias footx[a-zA-Z0-9]+=/d' "$RC" || true
  {
    echo 'footx() {'
    echo '  name="$1"'
    echo '  file="$HOME/.config/foot/foot.ini"'
    echo '  sed -i -E "s#^include=.*#include=~/.config/foot/themes/${name}.ini#" "$file"'
    echo '  if ! grep -q "^include=" "$file"; then'
    echo '    if grep -q "^\[main\]" "$file"; then'
    echo '      sed -i "/^\[main\]/a include=~/.config/foot/themes/${name}.ini" "$file"'
    echo '    else'
    echo '      { echo "[main]"; echo "include=~/.config/foot/themes/${name}.ini"; } >> "$file"'
    echo '    fi'
    echo '  fi'
    echo '}'
    echo 'alias footxx="footx x"'
    echo 'alias footxmadrid="footx madrid"'
    echo 'alias footxlahabana="footx lahabana"'

    echo 'alias footxmiami="footx miami"'
    echo 'alias footxparis="footx paris"'
    echo 'alias footxtokio="footx tokio"'
    echo 'alias footxoslo="footx oslo"'
    echo 'alias footxhelsinki="footx helsinki"'
    echo 'alias footxberlin="footx berlin"'
    echo 'alias footxlondon="footx london"'
    echo 'alias footxpraha="footx praha"'
    echo 'alias footxbogota="footx bogota"'
  } >> "$RC"
}

if command -v bash >/dev/null 2>&1; then
  append_aliases "$HOME/.bashrc"
  echo "Aliases added to ~/.bashrc"
fi
if command -v zsh >/dev/null 2>&1; then
  append_aliases "$HOME/.zshrc"
  echo "Aliases added to ~/.zshrc"
fi
echo "Foot installation completed."

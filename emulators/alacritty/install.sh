#!/usr/bin/env sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_THEMES_DIR="$SCRIPT_DIR/themes"
TARGET_CONFIG_DIR="$HOME/.config/alacritty"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/themes"
MAIN="$TARGET_CONFIG_DIR/alacritty.toml"

detect_pm() {
  for pm in apt-get dnf pacman zypper yum apk brew; do
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
          alacritty)
            brew install --cask alacritty
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
    pacman)
      $SUDO pacman -S --needed --noconfirm "$@"
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
    pacman)
      $SUDO pacman -S --needed --noconfirm unzip || true
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
command -v alacritty >/dev/null 2>&1 || MISSING="$MISSING alacritty"
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


RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/alacritty"
THEMES_FILES="x madrid lahabana miami paris tokio oslo helsinki berlin london praha bogota"

mkdir -p "$TARGET_CONFIG_DIR"
mkdir -p "$TARGET_THEMES_DIR"

USE_REMOTE=0
if [ ! -d "$SRC_THEMES_DIR" ] || [ -z "$(ls -1 "$SRC_THEMES_DIR"/*.toml 2>/dev/null)" ] || [ ! -f "$SCRIPT_DIR/alacritty.toml" ]; then
  USE_REMOTE=1
fi

if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local themes in $SRC_THEMES_DIR"
  for name in $THEMES_FILES; do
    if [ "$name" = "x" ]; then
      src="x.toml"
    else
      src="${name}.toml"
    fi
    if [ -f "$SRC_THEMES_DIR/$src" ]; then
      cp -f "$SRC_THEMES_DIR/$src" "$TARGET_THEMES_DIR/${name}.toml"
    else
      echo "Warning: local source theme not found: $SRC_THEMES_DIR/$src"
    fi
  done
else
  echo "Downloading themes from remote repository..."
  for name in $THEMES_FILES; do
    if [ "$name" = "x" ]; then
      src="x.toml"
    else
      src="${name}.toml"
    fi
    fetch_file "$RAW_BASE/themes/$src" "$TARGET_THEMES_DIR/${name}.toml"
  done
fi

if [ -f "$MAIN" ]; then
  TS="$(date +%s)"
  cp "$MAIN" "$MAIN.bak.$TS"
  echo "Backup created: $MAIN.bak.$TS"
fi
if [ "$USE_REMOTE" -eq 0 ]; then
  cp -f "$SCRIPT_DIR/alacritty.toml" "$MAIN"
else
  fetch_file "$RAW_BASE/alacritty.toml" "$MAIN"
fi
echo "Configuration file written: $MAIN"

sed_in_place() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

sed_in_place -E 's#^import = \[.*\]#import = ["themes/x.toml"]#' "$MAIN" || true
echo "Default theme set: themes/x.toml"

append_aliases() {
  RC="$1"
  [ -f "$RC" ] || touch "$RC"
  sed_in_place '/^alax() {/,/^}/d' "$RC" || true
  sed_in_place -E '/^alias alax[a-zA-Z0-9]+=/d' "$RC" || true
  {
    echo 'alax() {'
    echo '  name="$1"'
    echo '  file="$HOME/.config/alacritty/alacritty.toml"'
    echo '  if sed --version >/dev/null 2>&1; then'
    echo '    sed -i -E "s#^import = \\[.*\\]#import = [\\\"themes/${name}.toml\\\"]#" "$file"'
    echo '  else'
    echo '    sed -i "" -E "s#^import = \\[.*\\]#import = [\\\"themes/${name}.toml\\\"]#" "$file"'
    echo '  fi'
    echo '}'
    echo 'alias alaxx="alax x"'
    echo 'alias alaxmadrid="alax madrid"'
    echo 'alias alaxlahabana="alax lahabana"'

    echo 'alias alaxmiami="alax miami"'
    echo 'alias alaxparis="alax paris"'
    echo 'alias alaxtokio="alax tokio"'
    echo 'alias alaxoslo="alax oslo"'
    echo 'alias alaxhelsinki="alax helsinki"'
    echo 'alias alaxberlin="alax berlin"'
    echo 'alias alaxlondon="alax london"'
    echo 'alias alaxpraha="alax praha"'
    echo 'alias alaxbogota="alax bogota"'
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

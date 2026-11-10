#!/usr/bin/env sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_THEMES_DIR="$SCRIPT_DIR/themes"
SRC_STYLES_DIR="$SCRIPT_DIR/styles"
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/themes"
TARGET_STYLES_DIR="$TARGET_CONFIG_DIR/styles"
MAIN="$TARGET_CONFIG_DIR/config"
MAC_CONF="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

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

install_pkgs() {
  PM="$(detect_pm)" || { echo "No supported package manager found"; return 1; }
  SUDO="$(sudo_cmd)"
  echo "Using package manager: $PM"
  case "$PM" in
    brew)
      brew update
      for pkg in "$@"; do
        case "$pkg" in
          ghostty)
            brew install --cask ghostty
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
command -v ghostty >/dev/null 2>&1 || MISSING="$MISSING ghostty"
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

RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/ghostty"
THEMES_FILES="x.ini madrid.ini lahabana.ini miami.ini paris.ini tokio.ini oslo.ini helsinki.ini berlin.ini london.ini praha.ini bogota.ini"
STYLES_FILES="x.css madrid.css lahabana.css miami.css paris.css tokio.css oslo.css helsinki.css berlin.css london.css praha.css bogota.css"

mkdir -p "$TARGET_CONFIG_DIR"
mkdir -p "$TARGET_THEMES_DIR"
mkdir -p "$TARGET_STYLES_DIR"

USE_REMOTE=0
if [ ! -d "$SRC_THEMES_DIR" ] || [ -z "$(ls -1 "$SRC_THEMES_DIR"/*.ini 2>/dev/null)" ] || [ ! -f "$SCRIPT_DIR/config" ]; then
  USE_REMOTE=1
fi

if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local themes in $SRC_THEMES_DIR"
  for name in $THEMES_FILES; do
    [ -f "$SRC_THEMES_DIR/$name" ] && cp -f "$SRC_THEMES_DIR/$name" "$TARGET_THEMES_DIR/$name"
  done
  COUNT_T="$(ls -1 "$TARGET_THEMES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Themes installed: $COUNT_T in $TARGET_THEMES_DIR"
  echo "Using local styles in $SRC_STYLES_DIR"
  for s in $STYLES_FILES; do
    [ -f "$SRC_STYLES_DIR/$s" ] && cp -f "$SRC_STYLES_DIR/$s" "$TARGET_STYLES_DIR/$s"
  done
  COUNT_S="$(ls -1 "$TARGET_STYLES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Styles installed: $COUNT_S in $TARGET_STYLES_DIR"
else
  echo "Downloading themes from remote repository..."
  for name in $THEMES_FILES; do
    fetch_file "$RAW_BASE/themes/$name" "$TARGET_THEMES_DIR/$name"
  done
  COUNT_T="$(ls -1 "$TARGET_THEMES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Themes installed (remote): $COUNT_T in $TARGET_THEMES_DIR"
  echo "Downloading styles from remote repository..."
  for s in $STYLES_FILES; do
    fetch_file "$RAW_BASE/styles/$s" "$TARGET_STYLES_DIR/$s" || true
  done
  COUNT_S="$(ls -1 "$TARGET_STYLES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Styles installed (remote): $COUNT_S in $TARGET_STYLES_DIR"
fi

if [ -f "$MAIN" ]; then
  TS="$(date +%s)"
  cp "$MAIN" "$MAIN.bak.$TS"
  echo "Backup created: $MAIN.bak.$TS"
fi
if [ "$USE_REMOTE" -eq 0 ]; then
  cp -f "$SCRIPT_DIR/config" "$MAIN"
else
  fetch_file "$RAW_BASE/config" "$MAIN"
fi
echo "Configuration file written: $MAIN"

if [ "$(uname -s)" = "Darwin" ]; then
  mkdir -p "$(dirname "$MAC_CONF")"
  cp -f "$MAIN" "$MAC_CONF"
  echo "Configuration file written (macOS App Support): $MAC_CONF"
fi

sed_in_place() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

sed_in_place -E 's#^theme[[:space:]]*=.*#theme = x.ini#' "$MAIN" || true
grep -q '^theme[[:space:]]*=' "$MAIN" || {
  echo "theme = x.ini" >> "$MAIN"
}
echo "Default theme set: x.ini"
if grep -qE '^gtk-custom-css[[:space:]]*=' "$MAIN"; then
  sed_in_place -E 's#^gtk-custom-css[[:space:]]*=.*#gtk-custom-css = ~/.config/ghostty/styles/x.css#' "$MAIN"
else
  echo "gtk-custom-css = ~/.config/ghostty/styles/x.css" >> "$MAIN"
fi
echo "Default GTK CSS set: ~/.config/ghostty/styles/x.css"

append_aliases() {
  RC="$1"
  [ -f "$RC" ] || touch "$RC"
  sed_in_place '/^ghx() {/,/^}/d' "$RC" || true
  sed_in_place -E '/^alias ghx[a-zA-Z0-9]+=/d' "$RC" || true
  {
    echo 'ghx() {'
    echo '  name="$1"'
    echo '  file="$HOME/.config/ghostty/config"'
    echo '  if sed --version >/dev/null 2>&1; then'
    echo '    sed -i -E "s#^theme[[:space:]]*=.*#theme = ${name}.ini#" "$file"'
    echo '  else'
    echo '    sed -i "" -E "s#^theme[[:space:]]*=.*#theme = ${name}.ini#" "$file"'
    echo '  fi'
    echo '  grep -q "^theme[[:space:]]*=" "$file" || echo "theme = ${name}.ini" >> "$file"'
    echo '  if grep -qE "^gtk-custom-css[[:space:]]*=" "$file"; then'
    echo '    if sed --version >/dev/null 2>&1; then'
    echo '      sed -i -E "s#^gtk-custom-css[[:space:]]*=.*#gtk-custom-css = ~/.config/ghostty/styles/${name}.css#" "$file"'
    echo '    else'
    echo '      sed -i "" -E "s#^gtk-custom-css[[:space:]]*=.*#gtk-custom-css = ~/.config/ghostty/styles/${name}.css#" "$file"'
    echo '    fi'
    echo '  else'
    echo '    echo "gtk-custom-css = ~/.config/ghostty/styles/${name}.css" >> "$file"'
    echo '  fi'
    echo '}'
    echo 'alias ghxx="ghx x"'
    echo 'alias ghxmadrid="ghx madrid"'
    echo 'alias ghxlahabana="ghx lahabana"'

    echo 'alias ghxmiami="ghx miami"'
    echo 'alias ghxparis="ghx paris"'
    echo 'alias ghxtokio="ghx tokio"'
    echo 'alias ghxoslo="ghx oslo"'
    echo 'alias ghxhelsinki="ghx helsinki"'
    echo 'alias ghxberlin="ghx berlin"'
    echo 'alias ghxlondon="ghx london"'
    echo 'alias ghxpraha="ghx praha"'
    echo 'alias ghxbogota="ghx bogota"'
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
echo "Ghostty installation completed."

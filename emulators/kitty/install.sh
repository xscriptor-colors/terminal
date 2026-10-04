#!/usr/bin/env sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_THEMES_DIR="$SCRIPT_DIR/themes"
SRC_SHADERS_DIR="$SCRIPT_DIR/shaders"
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/themes"
TARGET_SHADERS_DIR="$TARGET_CONFIG_DIR/shaders"
MAIN="$TARGET_CONFIG_DIR/kitty.conf"
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
          kitty)
            brew install kitty
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
ensure_slangc() {
  if command -v slangc >/dev/null 2>&1; then
    return 0
  fi
  PM="$(detect_pm)" || {
    echo "Warning: slangc not found and no supported package manager detected."
    echo "Custom kitty shaders stay disabled until shader-slang is installed."
    return 0
  }
  if [ "$PM" = "pacman" ]; then
    SUDO="$(sudo_cmd)"
    echo "Installing shader-slang (required by the custom kitty shaders)..."
    $SUDO pacman -S --needed --noconfirm shader-slang || true
    if command -v slangc >/dev/null 2>&1; then
      echo "shader-slang installed: $(command -v slangc)"
      return 0
    fi
  fi
  echo "Warning: slangc was not found. Custom kitty shaders stay disabled."
  echo "  Arch:  sudo pacman -S shader-slang"
  echo "  Other: install shader-slang from your package manager or"
  echo "         https://github.com/shader-slang/slang/releases"
  echo "  If slangc is not in PATH, launch kitty with SLANGC=/path/to/slangc."
}
ensure_unzip || true
MISSING=""
command -v kitty >/dev/null 2>&1 || MISSING="$MISSING kitty"
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
    echo "ERROR: Font file not downloaded. Please install Hack Nerd Font manually."
    echo "Download from: https://github.com/ryanoasis/nerd-fonts/releases"
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
RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/kitty"
THEMES_FILES="x.conf madrid.conf lahabana.conf miami.conf paris.conf tokio.conf oslo.conf helsinki.conf berlin.conf london.conf praha.conf bogota.conf"
SHADERS_FILES="x-glow.slang x-trail.pipeline"
mkdir -p "$TARGET_CONFIG_DIR"
mkdir -p "$TARGET_THEMES_DIR"
mkdir -p "$TARGET_SHADERS_DIR"
USE_REMOTE=0
if [ ! -d "$SRC_THEMES_DIR" ] || [ -z "$(ls -1 "$SRC_THEMES_DIR"/*.conf 2>/dev/null)" ] || [ ! -f "$SCRIPT_DIR/config" ]; then
  USE_REMOTE=1
fi
if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local themes in $SRC_THEMES_DIR"
  for f in "$SRC_THEMES_DIR"/*.conf; do
    [ -f "$f" ] && cp -f "$f" "$TARGET_THEMES_DIR/$(basename "$f")"
  done
  COUNT_T="$(ls -1 "$TARGET_THEMES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Themes installed: $COUNT_T in $TARGET_THEMES_DIR"
else
  echo "Downloading themes from remote repository..."
  for name in $THEMES_FILES; do
    fetch_file "$RAW_BASE/themes/$name" "$TARGET_THEMES_DIR/$name"
  done
  COUNT_T="$(ls -1 "$TARGET_THEMES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Themes installed (remote): $COUNT_T in $TARGET_THEMES_DIR"
fi
if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local shaders in $SRC_SHADERS_DIR"
  for f in "$SRC_SHADERS_DIR"/*.slang "$SRC_SHADERS_DIR"/*.pipeline; do
    if [ -f "$f" ]; then
      cp -f "$f" "$TARGET_SHADERS_DIR/$(basename "$f")"
    fi
  done
  COUNT_S="$(ls -1 "$TARGET_SHADERS_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Shaders installed: $COUNT_S in $TARGET_SHADERS_DIR"
else
  echo "Downloading shaders from remote repository..."
  for name in $SHADERS_FILES; do
    fetch_file "$RAW_BASE/shaders/$name" "$TARGET_SHADERS_DIR/$name"
  done
  COUNT_S="$(ls -1 "$TARGET_SHADERS_DIR" 2>/dev/null | wc -l | tr -d ' ')"
  echo "Shaders installed (remote): $COUNT_S in $TARGET_SHADERS_DIR"
fi
ensure_slangc
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
  sed -i '' -E '/^include[[:space:]]+themes\/.*\.conf/d' "$MAIN" || true
else
  sed -i -E '/^include[[:space:]]+themes\/.*\.conf/d' "$MAIN" || true
fi
# Ensure file ends with newline before appending include
[ -n "$(tail -c1 "$MAIN")" ] && echo "" >> "$MAIN"
echo "include themes/x.conf" >> "$MAIN"
echo "Default theme set: x.conf"
append_aliases() {
  RC="$1"
  [ -f "$RC" ] || touch "$RC"
  if [ "$(uname -s)" = "Darwin" ]; then
    sed -i '' '/^kix() {/,/^}/d' "$RC" || true
    sed -i '' -E '/^alias kix[a-zA-Z0-9]+=/d' "$RC" || true
  else
    sed -i '/^kix() {/,/^}/d' "$RC" || true
    sed -i -E '/^alias kix[a-zA-Z0-9]+=/d' "$RC" || true
  fi
  {
    echo 'kix() {'
    echo '  name="$1"'
    echo '  themes_dir="$HOME/.config/kitty/themes"'
    echo '  file="$HOME/.config/kitty/kitty.conf"'
    echo '  if [ ! -f "$themes_dir/${name}.conf" ]; then'
    echo '    echo "Error: Theme '\''${name}'\''\ not found in $themes_dir"'
    echo '    echo "Available themes: $(ls -1 "$themes_dir" 2>/dev/null | sed "s/.conf//g" | tr "\n" " ")"'
    echo '    return 1'
    echo '  fi'
    echo '  if [ "$(uname -s)" = "Darwin" ]; then'
    echo '    sed -i '\'\'' -E "/^include[[:space:]]+themes\/.*\.conf/d" "$file"'
    echo '  else'
    echo '    sed -i -E "/^include[[:space:]]+themes\/.*\.conf/d" "$file"'
    echo '  fi'
    echo '  echo "include themes/${name}.conf" >> "$file"'
    echo '  echo "Theme changed to: ${name}"'
    echo '}'
    echo 'alias kixx="kix x"'
    echo 'alias kixmadrid="kix madrid"'
    echo 'alias kixlahabana="kix lahabana"'

    echo 'alias kixmiami="kix miami"'
    echo 'alias kixparis="kix paris"'
    echo 'alias kixtokio="kix tokio"'
    echo 'alias kixoslo="kix oslo"'
    echo 'alias kixhelsinki="kix helsinki"'
    echo 'alias kixberlin="kix berlin"'
    echo 'alias kixlondon="kix london"'
    echo 'alias kixpraha="kix praha"'
    echo 'alias kixbogota="kix bogota"'
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
echo "Kitty installation completed."

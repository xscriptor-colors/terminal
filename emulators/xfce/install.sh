#!/usr/bin/env sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")"
SRC_THEMES_DIR="$SCRIPT_DIR/themes"
TARGET_DIR="$HOME/.local/share/xfce4/terminal/colorschemes"
RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/xfce/themes"
THEMES_FILES="x.theme madrid.theme lahabana.theme miami.theme paris.theme tokio.theme oslo.theme helsinki.theme berlin.theme london.theme praha.theme bogota.theme"

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
  [ -z "$CMD" ] && { echo "curl or wget is required"; exit 1; }
  if [ "$CMD" = "curl" ]; then
    curl -fsSL -o "$DEST" "$URL"
  else
    wget -qO "$DEST" "$URL"
  fi
}

install_pkgs() {
  PM="$(detect_pm)" || { echo "No supported package manager found"; return 1; }
  SUDO="$(sudo_cmd)"
  case "$PM" in
    brew)
      brew update
      command -v curl >/dev/null 2>&1 || brew install curl || true
      ;;
    apt-get)
      $SUDO apt-get update
      $SUDO apt-get install -y xfce4-terminal curl || $SUDO apt-get install -y wget || true
      ;;
    dnf)
      $SUDO dnf install -y xfce4-terminal curl || $SUDO dnf install -y wget || true
      ;;
    xpm|pacman)
      $SUDO "$PM" -S --needed --noconfirm xfce4-terminal curl || $SUDO "$PM" -S --needed --noconfirm wget || true
      ;;
    zypper)
      $SUDO zypper refresh
      $SUDO zypper install -y xfce4-terminal curl || $SUDO zypper install -y wget || true
      ;;
    yum)
      $SUDO yum install -y xfce4-terminal curl || $SUDO yum install -y wget || true
      ;;
    apk)
      $SUDO apk update
      $SUDO apk add xfce4-terminal curl || $SUDO apk add wget || true
      ;;
    *)
      return 1
      ;;
  esac
}

echo "Installing Xscriptor themes for XFCE Terminal..."
command -v xfce4-terminal >/dev/null 2>&1 || install_pkgs || true

mkdir -p "$TARGET_DIR"

USE_REMOTE=0
if [ ! -d "$SRC_THEMES_DIR" ] || [ -z "$(ls -1 "$SRC_THEMES_DIR"/*.theme 2>/dev/null)" ]; then
  USE_REMOTE=1
fi

if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local themes in $SRC_THEMES_DIR"
  for name in $THEMES_FILES; do
    src="$SRC_THEMES_DIR/$name"
    if [ -f "$src" ]; then
      cp -f "$src" "$TARGET_DIR/$(basename "$src")"
    else
      echo "Warning: local theme not found: $name"
    fi
  done
else
  echo "Downloading themes from remote repository"
  for name in $THEMES_FILES; do
    fetch_file "$RAW_BASE/$name" "$TARGET_DIR/$name" || echo "Warning: remote theme not found: $name"
  done
fi

COUNT_T="$(ls -1 "$TARGET_DIR" 2>/dev/null | wc -l | tr -d ' ')"
echo "Themes installed: $COUNT_T in $TARGET_DIR"
echo "Apply a theme in XFCE Terminal: Edit > Preferences > Colors > Presets"

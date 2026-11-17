#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_THEMES_DIR="$SCRIPT_DIR/themes"
TARGET_THEMES_DIR="$HOME/.local/share/konsole"

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

install_pkgs() {
  PM="$(detect_pm)" || { echo "No supported package manager found"; return 1; }
  SUDO="$(sudo_cmd)"
  echo "Using package manager: $PM"
  case "$PM" in
    brew)
      brew update
      for pkg in "$@"; do
        brew install "$pkg" || true
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

echo "Installing Xscriptor themes for Konsole..."
MISSING=""
command -v konsole >/dev/null 2>&1 || MISSING="$MISSING konsole"
command -v sed >/dev/null 2>&1 || MISSING="$MISSING sed"
if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
  MISSING="$MISSING curl"
fi
if [ -n "$MISSING" ]; then
  echo "Installing missing packages:$MISSING"
  install_pkgs $MISSING || { echo "Error installing required packages:$MISSING"; exit 1; }
fi

RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/konsole"
THEMES_FILES="x.colorscheme madrid.colorscheme lahabana.colorscheme miami.colorscheme paris.colorscheme tokio.colorscheme oslo.colorscheme helsinki.colorscheme berlin.colorscheme london.colorscheme praha.colorscheme bogota.colorscheme"

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

mkdir -p "$TARGET_THEMES_DIR"

USE_REMOTE=0
if [ ! -d "$SRC_THEMES_DIR" ] || [ -z "$(ls -1 "$SRC_THEMES_DIR"/*.colorscheme 2>/dev/null)" ]; then
  USE_REMOTE=1
fi

if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local themes in $SRC_THEMES_DIR"
  for f in "$SRC_THEMES_DIR"/*.colorscheme; do
    [ -f "$f" ] && cp -f "$f" "$TARGET_THEMES_DIR/$(basename "$f")"
  done
else
  echo "Downloading themes from remote repository..."
  for name in $THEMES_FILES; do
    fetch_file "$RAW_BASE/themes/$name" "$TARGET_THEMES_DIR/$name"
  done
fi

COUNT_T="$(ls -1 "$TARGET_THEMES_DIR" 2>/dev/null | wc -l | tr -d ' ')"
echo "Themes installed: $COUNT_T in $TARGET_THEMES_DIR"

append_aliases() {
  RC="$1"
  [ -f "$RC" ] || touch "$RC"
  sed -i '/^knx() {/,/^}/d' "$RC" || true
  sed -i -E '/^alias knx[a-zA-Z0-9]+=/d' "$RC" || true
  {
    echo 'knx() {'
    echo '  name="$1"'
    echo '  if command -v konsoleprofile >/dev/null 2>&1; then'
    echo '    konsoleprofile "colors=${name}" || konsoleprofile "ColorScheme=${name}" || true'
    echo '  else'
    echo '    echo "konsoleprofile not found; open Settings > Edit Current Profile > Appearance and select the scheme manually."'
    echo '    return 1'
    echo '  fi'
    echo '}'
    echo 'alias knxx="knx x"'
    echo 'alias knxmadrid="knx madrid"'
    echo 'alias knxlahabana="knx lahabana"'

    echo 'alias knxmiami="knx miami"'
    echo 'alias knxparis="knx paris"'
    echo 'alias knxtokio="knx tokio"'
    echo 'alias knxoslo="knx oslo"'
    echo 'alias knxhelsinki="knx helsinki"'
    echo 'alias knxberlin="knx berlin"'
    echo 'alias knxlondon="knx london"'
    echo 'alias knxpraha="knx praha"'
    echo 'alias knxbogota="knx bogota"'
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

if command -v konsoleprofile >/dev/null 2>&1; then
  konsoleprofile "colors=x" || konsoleprofile "ColorScheme=x" || true
fi

echo "Konsole themes installation completed."

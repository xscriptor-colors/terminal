#!/usr/bin/env sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_CONFIG_DIR="$HOME/.config/terminator"
MAIN="$TARGET_CONFIG_DIR/config"

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
  PM="$(detect_pm)" || { echo "No supported package manager found"; return 0; }
  SUDO="$(sudo_cmd)"
  case "$PM" in
    brew)
      for pkg in "$@"; do
        case "$pkg" in
          terminator)
            echo "Skipping terminator installation on macOS"
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
      return 0
      ;;
  esac
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

RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/terminator"

mkdir -p "$TARGET_CONFIG_DIR"

MISSING=""
command -v terminator >/dev/null 2>&1 || MISSING="$MISSING terminator"
if [ -n "$MISSING" ]; then
  install_pkgs $MISSING || true
fi

USE_REMOTE=0
[ -f "$SCRIPT_DIR/config" ] || USE_REMOTE=1

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

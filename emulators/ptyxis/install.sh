#!/usr/bin/env sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/themes"
DEST_DIR="$HOME/.local/share/org.gnome.Ptyxis/palettes"

echo "Starting Ptyxis themes installation..."

RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/ptyxis"
THEMES_FILES="x.palette madrid.palette lahabana.palette miami.palette paris.palette tokio.palette oslo.palette helsinki.palette berlin.palette london.palette praha.palette bogota.palette"

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
  case "$PM" in
    brew)
      for pkg in "$@"; do
        case "$pkg" in
          curl|wget|sed)
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

ensure_deps() {
  MISSING=""
  command -v sed >/dev/null 2>&1 || MISSING="$MISSING sed"
  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    MISSING="$MISSING curl"
  fi
  if [ -n "$MISSING" ]; then
    echo "Installing missing packages:$MISSING"
    install_pkgs $MISSING || { echo "Warning: failed to install some packages:$MISSING"; }
  fi
}

sed_in_place() {
  EXP="$1"
  FILE="$2"
  if sed --version >/dev/null 2>&1; then
    sed -i -E "$EXP" "$FILE"
  else
    sed -i '' -E "$EXP" "$FILE"
  fi
}

set_primary_palette() {
  NAME="$1"
  [ -d "$DEST_DIR" ] || return 0
  for f in "$DEST_DIR"/*.palette; do
    [ -f "$f" ] && sed_in_place 's/^Primary\s*=\s*true/Primary=false/' "$f"
  done
  FILE="$DEST_DIR/$NAME.palette"
  [ -f "$FILE" ] && sed_in_place 's/^Primary\s*=.*/Primary=true/' "$FILE"
}

append_aliases() {
  RC="$1"
  [ -f "$RC" ] || touch "$RC"
  if sed --version >/dev/null 2>&1; then
    sed -i '/^ptyx() {/,/^}/d' "$RC" || true
    sed -i -E '/^alias ptyx[a-zA-Z0-9]+=/d' "$RC" || true
  else
    sed -i '' '/^ptyx() {/,/^}/d' "$RC" || true
    sed -i '' -E '/^alias ptyx[a-zA-Z0-9]+=/d' "$RC" || true
  fi
  {
    echo 'ptyx() {'
    echo '  name="$1"'
    echo '  dir="$HOME/.local/share/org.gnome.Ptyxis/palettes"'
    echo '  file="$dir/${name}.palette"'
    echo '  if [ ! -f "$file" ]; then'
    echo '    echo "Palette not found: $file"'
    echo '    return 1'
    echo '  fi'
    echo '  if sed --version >/dev/null 2>&1; then'
    echo '    for f in "$dir"/*.palette; do [ -f "$f" ] && sed -i -E "s/^Primary\\s*=\\s*true/Primary=false/" "$f"; done'
    echo '    sed -i -E "s/^Primary\\s*=.*/Primary=true/" "$file"'
    echo '  else'
    echo '    for f in "$dir"/*.palette; do [ -f "$f" ] && sed -i "" -E "s/^Primary\\s*=\\s*true/Primary=false/" "$f"; done'
    echo '    sed -i "" -E "s/^Primary\\s*=.*/Primary=true/" "$file"'
    echo '  fi'
    echo '}'
    echo 'alias ptyxx="ptyx x"'
    echo 'alias ptyxmadrid="ptyx madrid"'
    echo 'alias ptyxlahabana="ptyx lahabana"'

    echo 'alias ptyxmiami="ptyx miami"'
    echo 'alias ptyxparis="ptyx paris"'
    echo 'alias ptyxtokio="ptyx tokio"'
    echo 'alias ptyxoslo="ptyx oslo"'
    echo 'alias ptyxhelsinki="ptyx helsinki"'
    echo 'alias ptyxberlin="ptyx berlin"'
    echo 'alias ptyxlondon="ptyx london"'
    echo 'alias ptyxpraha="ptyx praha"'
    echo 'alias ptyxbogota="ptyx bogota"'
  } >> "$RC"
}

ensure_deps || true
mkdir -p "$DEST_DIR"
echo "Target palettes directory: $DEST_DIR"

USE_REMOTE=0
if [ ! -d "$SRC_DIR" ] || [ -z "$(ls -1 "$SRC_DIR"/*.palette 2>/dev/null)" ]; then
  USE_REMOTE=1
fi

if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local palettes in $SRC_DIR"
  for f in "$SRC_DIR"/*.palette; do
    [ -f "$f" ] && cp -f "$f" "$DEST_DIR/$(basename "$f")"
  done
else
  echo "Downloading palettes from remote repository..."
  for name in $THEMES_FILES; do
    fetch_file "$RAW_BASE/themes/$name" "$DEST_DIR/$name"
  done
fi

COUNT="$(ls -1 "$DEST_DIR" 2>/dev/null | wc -l | tr -d ' ')"
echo "Palettes installed: $COUNT in $DEST_DIR"

set_primary_palette "x"
echo "Default palette set: x.palette"

if command -v bash >/dev/null 2>&1; then
  append_aliases "$HOME/.bashrc"
  echo "Aliases added to ~/.bashrc"
fi
if command -v zsh >/dev/null 2>&1; then
  append_aliases "$HOME/.zshrc"
  echo "Aliases added to ~/.zshrc"
fi

echo "Ptyxis themes installation completed."

#!/usr/bin/env sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DCONF_DIR="$SCRIPT_DIR/dconf"

UUID_X="6e8b5e50-1c2a-4a22-9a10-000000000001"
UUID_MADRID="6e8b5e50-1c2a-4a22-9a10-000000000002"
UUID_LAHABANA="6e8b5e50-1c2a-4a22-9a10-000000000003"

UUID_MIAMI="6e8b5e50-1c2a-4a22-9a10-000000000005"
UUID_PARIS="6e8b5e50-1c2a-4a22-9a10-000000000006"
UUID_TOKIO="6e8b5e50-1c2a-4a22-9a10-000000000007"
UUID_OSLO="6e8b5e50-1c2a-4a22-9a10-000000000008"
UUID_HELSINKI="6e8b5e50-1c2a-4a22-9a10-000000000009"
UUID_BERLIN="6e8b5e50-1c2a-4a22-9a10-00000000000a"
UUID_LONDON="6e8b5e50-1c2a-4a22-9a10-00000000000b"
UUID_PRAHA="6e8b5e50-1c2a-4a22-9a10-00000000000c"
UUID_BOGOTA="6e8b5e50-1c2a-4a22-9a10-00000000000d"

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
        case "$pkg" in
          dconf|glib)
            brew install "$pkg" || true
            ;;
          *)
            brew install "$pkg" || true
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

MISSING=""
command -v dconf >/dev/null 2>&1 || MISSING="$MISSING dconf-cli"
command -v gsettings >/dev/null 2>&1 || MISSING="$MISSING glib2"
command -v sed >/dev/null 2>&1 || MISSING="$MISSING sed"
if [ -n "$MISSING" ]; then
  echo "Installing missing packages:$MISSING"
  install_pkgs $MISSING || { echo "Error installing required packages:$MISSING"; exit 1; }
fi

ensure_gnome_terminal() {
  if command -v gnome-terminal >/dev/null 2>&1; then
    echo "gnome-terminal is already installed"
    return 0
  fi
  PM="$(detect_pm)" || { echo "No supported package manager found to install gnome-terminal"; return 1; }
  SUDO="$(sudo_cmd)"
  echo "Installing gnome-terminal with $PM..."
  case "$PM" in
    brew)
      echo "GNOME Terminal is not available via Homebrew on macOS"
      ;;
    apt-get)
      $SUDO apt-get update
      $SUDO apt-get install -y gnome-terminal || true
      ;;
    dnf)
      $SUDO dnf install -y gnome-terminal || true
      ;;
    xpm|pacman)
      $SUDO "$PM" -S --needed --noconfirm gnome-terminal || true
      ;;
    zypper)
      $SUDO zypper refresh
      $SUDO zypper install -y gnome-terminal || true
      ;;
    yum)
      $SUDO yum install -y gnome-terminal || true
      ;;
    apk)
      echo "GNOME Terminal is not available on Alpine (apk)"
      ;;
    *)
      echo "Unsupported package manager for automatic GNOME Terminal install"
      ;;
  esac
}

ensure_gnome_terminal || true

RAW_BASE="https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/gnome-terminal"
THEMES_FILES="x madrid lahabana miami paris tokio oslo helsinki berlin london praha bogota"

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

load_theme_dconf() {
  FILE="$1"
  if [ -f "$FILE" ]; then
    dconf load /org/gnome/terminal/ < "$FILE"
    return 0
  fi
  return 1
}

ensure_uuid_in_list() {
  UUID="$1"
  CURRENT="$(gsettings get org.gnome.Terminal.ProfilesList list)"
  if echo "$CURRENT" | grep -q "'$UUID'"; then
    NEW="$CURRENT"
  else
    if [ "$CURRENT" = "[]" ]; then
      NEW="['$UUID']"
    else
      NEW="$(echo "$CURRENT" | sed "s/]$/, '$UUID']/")"
    fi
  fi
  gsettings set org.gnome.Terminal.ProfilesList list "$NEW"
}

set_default_profile() {
  UUID="$1"
  gsettings set org.gnome.Terminal.ProfilesList default "'$UUID'"
}

TMPDL="$(mktemp -d)"
USE_REMOTE=0
if [ ! -d "$SRC_DCONF_DIR" ] || [ -z "$(ls -1 "$SRC_DCONF_DIR"/*.dconf 2>/dev/null)" ]; then
  USE_REMOTE=1
fi

COUNT_LOADED=0
if [ "$USE_REMOTE" -eq 0 ]; then
  echo "Using local dconf themes in $SRC_DCONF_DIR"
  for name in $THEMES_FILES; do
    file="$SRC_DCONF_DIR/${name}.dconf"
    if [ -f "$file" ]; then
      load_theme_dconf "$file" && COUNT_LOADED=$((COUNT_LOADED+1))
    else
      echo "Theme not found locally: ${name}.dconf"
    fi
  done
else
  echo "Downloading dconf themes from remote repository..."
  for name in $THEMES_FILES; do
    target="$TMPDL/${name}.dconf"
    if ! fetch_file "$RAW_BASE/dconf/${name}.dconf" "$target"; then
      echo "Theme not available remotely: ${name}.dconf"
      continue
    fi
    load_theme_dconf "$target" && COUNT_LOADED=$((COUNT_LOADED+1))
  done
fi
echo "Loaded $COUNT_LOADED GNOME Terminal theme profiles"
rm -rf "$TMPDL"

for UUID in \
  "$UUID_X" "$UUID_MADRID" "$UUID_LAHABANA" "$UUID_MIAMI" \
  "$UUID_PARIS" "$UUID_TOKIO" "$UUID_OSLO" "$UUID_HELSINKI" "$UUID_BERLIN" "$UUID_LONDON" \
  "$UUID_PRAHA" "$UUID_BOGOTA"
do
  ensure_uuid_in_list "$UUID"
done
echo "Ensured all theme UUIDs are present in the ProfilesList"

set_default_profile "$UUID_X"
echo "Default GNOME Terminal profile set to x ($UUID_X)"

append_aliases() {
  RC="$1"
  [ -f "$RC" ] || touch "$RC"
  sed -i '/^gtx() {/,/^}/d' "$RC" || true
  sed -i -E '/^alias gtx[a-zA-Z0-9]+=/d' "$RC" || true
  {
    echo 'gtx() {'
    echo '  name="$1"'
    echo '  case "$name" in'
    echo '    x) uuid="'"$UUID_X"'" ;;'
    echo '    madrid) uuid="'"$UUID_MADRID"'" ;;'
    echo '    lahabana) uuid="'"$UUID_LAHABANA"'" ;;'

    echo '    miami) uuid="'"$UUID_MIAMI"'" ;;'
    echo '    paris) uuid="'"$UUID_PARIS"'" ;;'
    echo '    tokio) uuid="'"$UUID_TOKIO"'" ;;'
    echo '    oslo) uuid="'"$UUID_OSLO"'" ;;'
    echo '    helsinki) uuid="'"$UUID_HELSINKI"'" ;;'
    echo '    berlin) uuid="'"$UUID_BERLIN"'" ;;'
    echo '    london) uuid="'"$UUID_LONDON"'" ;;'
    echo '    praha) uuid="'"$UUID_PRAHA"'" ;;'
    echo '    bogota) uuid="'"$UUID_BOGOTA"'" ;;'
    echo '    *) echo "Unknown theme name: $name"; return 1 ;;'
    echo '  esac'
    echo '  gsettings set org.gnome.Terminal.ProfilesList default "'"'\$uuid'"'"'
    echo '}'
    echo 'alias gtxx="gtx x"'
    echo 'alias gtxmadrid="gtx madrid"'
    echo 'alias gtxlahabana="gtx lahabana"'

    echo 'alias gtxmiami="gtx miami"'
    echo 'alias gtxparis="gtx paris"'
    echo 'alias gtxtokio="gtx tokio"'
    echo 'alias gtxoslo="gtx oslo"'
    echo 'alias gtxhelsinki="gtx helsinki"'
    echo 'alias gtxberlin="gtx berlin"'
    echo 'alias gtxlondon="gtx london"'
    echo 'alias gtxpraha="gtx praha"'
    echo 'alias gtxbogota="gtx bogota"'
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

echo "GNOME Terminal themes installation completed."

#!/usr/bin/env sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/themes"
TARGET_STYLES_DIR="$TARGET_CONFIG_DIR/styles"
MAIN="$TARGET_CONFIG_DIR/config"
MAC_CONF="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

THEMES_FILES="x.ini madrid.ini lahabana.ini miami.ini paris.ini tokio.ini oslo.ini helsinki.ini berlin.ini london.ini praha.ini bogota.ini"
STYLES_FILES="x.css madrid.css lahabana.css miami.css paris.css tokio.css oslo.css helsinki.css berlin.css london.css praha.css bogota.css"

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

echo "Starting Ghostty uninstaller..."

# Remove aliases and helper function from shell RC files
remove_aliases() {
  RC="$1"
  [ -f "$RC" ] || return 0
  sed -i '/^ghx() {/,/^}/d' "$RC" || true
  sed -i -E '/^alias ghx[a-zA-Z0-9]+=/d' "$RC" || true
}

remove_aliases "$HOME/.bashrc" && echo "Removed aliases from ~/.bashrc" || true
remove_aliases "$HOME/.zshrc" && echo "Removed aliases from ~/.zshrc" || true

# Remove our installed theme files
mkdir -p "$TARGET_THEMES_DIR"
mkdir -p "$TARGET_STYLES_DIR"
REMOVED=0
for name in $THEMES_FILES; do
  if [ -f "$TARGET_THEMES_DIR/$name" ]; then
    rm -f "$TARGET_THEMES_DIR/$name"
    REMOVED=$((REMOVED+1))
  fi
done
echo "Removed $REMOVED theme files from $TARGET_THEMES_DIR"
REMOVED_STYLES=0
for s in $STYLES_FILES; do
  if [ -f "$TARGET_STYLES_DIR/$s" ]; then
    rm -f "$TARGET_STYLES_DIR/$s"
    REMOVED_STYLES=$((REMOVED_STYLES+1))
  fi
done
[ "$REMOVED_STYLES" -gt 0 ] && echo "Removed $REMOVED_STYLES style files from $TARGET_STYLES_DIR" || true

# Restore config backup or remove our theme line
restore_config_file() {
  FILE="$1"
  [ -f "$FILE" ] || { echo "Config not found: $FILE"; return 0; }
  LATEST="$(ls -1t "$FILE".bak.* 2>/dev/null | head -1 || true)"
  if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
    cp -f "$LATEST" "$FILE"
    echo "Restored backup: $LATEST -> $FILE"
    return 0
  fi
  if grep -Eq '^theme[[:space:]]*=[[:space:]]*(x\.ini|madrid\.ini|lahabana\.ini|miami\.ini|paris\.ini|tokio\.ini|oslo\.ini|helsinki\.ini|berlin\.ini|london\.ini|praha\.ini|bogota\.ini)[[:space:]]*$' "$FILE"; then
    sed -i -E '/^theme[[:space:]]*=/d' "$FILE"
    echo "Removed theme line from $FILE"
  fi
  if grep -Eq '^gtk-custom-css[[:space:]]*=[[:space:]]*.*ghostty/styles/.*\.css[[:space:]]*$' "$FILE"; then
    sed -i -E '/^gtk-custom-css[[:space:]]*=/d' "$FILE"
    echo "Removed gtk-custom-css from $FILE"
  else
    echo "Left config unchanged: $FILE"
  fi
}

restore_config_file "$MAIN"
restore_config_file "$MAC_CONF"

# Prompt to uninstall Ghostty
PM="$(detect_pm)" || PM=""
SUDO="$(sudo_cmd)"
if [ -t 0 ]; then
  printf "Do you also want to uninstall Ghostty? [y/N] "
  read -r REPLY_GHOSTTY
else
  REPLY_GHOSTTY="N"
fi
if [ "$REPLY_GHOSTTY" = "y" ] || [ "$REPLY_GHOSTTY" = "Y" ]; then
  if [ -n "$PM" ]; then
    echo "Uninstalling Ghostty with $PM..."
    case "$PM" in
      brew)
        brew uninstall --cask ghostty || true
        ;;
      apt-get)
        $SUDO apt-get remove --purge -y ghostty || true
        ;;
      dnf)
        $SUDO dnf remove -y ghostty || true
        ;;
      xpm|pacman)
        $SUDO "$PM" -Rns --noconfirm ghostty || true
        ;;
      zypper)
        $SUDO zypper remove -y ghostty || true
        ;;
      yum)
        $SUDO yum remove -y ghostty || true
        ;;
      apk)
        $SUDO apk del ghostty || true
        ;;
      *)
        echo "Unsupported package manager for automatic uninstall"
        ;;
    esac
  else
    echo "No supported package manager found to uninstall Ghostty"
  fi
else
  echo "Keeping Ghostty installed"
fi

# Prompt to uninstall Hack Nerd Font
if [ -t 0 ]; then
  printf "Do you also want to uninstall Hack Nerd Font? [y/N] "
  read -r REPLY_FONT
else
  REPLY_FONT="N"
fi
if [ "$REPLY_FONT" = "y" ] || [ "$REPLY_FONT" = "Y" ]; then
  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      echo "Uninstalling Hack Nerd Font (macOS, Homebrew cask)..."
      brew uninstall --cask font-hack-nerd-font || true
      ;;
    *)
      DEST="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/NerdFonts/Hack"
      if [ -d "$DEST" ]; then
        echo "Removing fonts at: $DEST"
        rm -rf "$DEST"
        echo "Updating font cache..."
        fc-cache -f >/dev/null 2>&1 || true
        echo "Font cache updated"
      else
        echo "Hack Nerd Font directory not found: $DEST"
      fi
      ;;
  esac
else
  echo "Keeping Hack Nerd Font installed"
fi

echo "Ghostty uninstall completed."

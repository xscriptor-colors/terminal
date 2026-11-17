#!/usr/bin/env sh
set -e

TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/foot"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/themes"
MAIN="$TARGET_CONFIG_DIR/foot.ini"
THEMES_FILES="x.ini madrid.ini lahabana.ini miami.ini paris.ini tokio.ini oslo.ini helsinki.ini berlin.ini london.ini praha.ini bogota.ini"

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

remove_aliases() {
  RC="$1"
  [ -f "$RC" ] || return 0
  sed -i '/^footx() {/,/^}/d' "$RC" || true
  sed -i -E '/^alias footx[a-zA-Z0-9]+=/d' "$RC" || true
}

remove_aliases "$HOME/.bashrc" || true
remove_aliases "$HOME/.zshrc" || true
echo "Removed Foot aliases from shell RC files"

mkdir -p "$TARGET_THEMES_DIR"
REMOVED=0
for name in $THEMES_FILES; do
  if [ -f "$TARGET_THEMES_DIR/$name" ]; then
    rm -f "$TARGET_THEMES_DIR/$name"
    REMOVED=$((REMOVED+1))
  fi
done
echo "Removed $REMOVED Foot theme files from $TARGET_THEMES_DIR"

restore_config_file() {
  FILE="$1"
  [ -f "$FILE" ] || { echo "Config not found: $FILE"; return 0; }
  LATEST="$(ls -1t "$FILE".bak.* 2>/dev/null | head -1 || true)"
  if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
    cp -f "$LATEST" "$FILE"
    echo "Restored backup: $LATEST -> $FILE"
    return 0
  fi
  if grep -Eq '^include[[:space:]]*=.*(x\.ini|madrid\.ini|lahabana\.ini|miami\.ini|paris\.ini|tokio\.ini|oslo\.ini|helsinki\.ini|berlin\.ini|london\.ini|praha\.ini|bogota\.ini)[[:space:]]*$' "$FILE"; then
    sed -i -E '/^include[[:space:]]*=/d' "$FILE"
    echo "Removed include line from $FILE"
  else
    echo "Left config unchanged: $FILE"
  fi
}

restore_config_file "$MAIN"

PM="$(detect_pm)" || PM=""
SUDO="$(sudo_cmd)"
if [ -t 0 ]; then
  printf "Do you also want to uninstall Foot? [y/N] "
  read -r REPLY_FOOT
else
  REPLY_FOOT="N"
fi
if [ "$REPLY_FOOT" = "y" ] || [ "$REPLY_FOOT" = "Y" ]; then
  if [ -n "$PM" ]; then
    echo "Uninstalling Foot with $PM..."
    case "$PM" in
      brew)
        brew uninstall foot || true
        ;;
      apt-get)
        $SUDO apt-get remove --purge -y foot || true
        ;;
      dnf)
        $SUDO dnf remove -y foot || true
        ;;
      xpm|pacman)
        $SUDO "$PM" -Rns --noconfirm foot || true
        ;;
      zypper)
        $SUDO zypper remove -y foot || true
        ;;
      yum)
        $SUDO yum remove -y foot || true
        ;;
      apk)
        $SUDO apk del foot || true
        ;;
      *)
        echo "Unsupported package manager for automatic uninstall"
        ;;
    esac
  else
    echo "No supported package manager found to uninstall Foot"
  fi
else
  echo "Keeping Foot installed"
fi

if [ -t 0 ]; then
  printf "Do you also want to uninstall Hack Nerd Font? [y/N] "
  read -r REPLY_FONT
else
  REPLY_FONT="N"
fi
if [ "$REPLY_FONT" = "y" ] || [ "$REPLY_FONT" = "Y" ]; then
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
else
  echo "Keeping Hack Nerd Font installed"
fi

echo "Foot uninstall completed."

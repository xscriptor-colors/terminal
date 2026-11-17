#!/usr/bin/env sh
set -e

TARGET_DIR="$HOME/.local/share/xfce4/terminal/colorschemes"
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

ASSUME_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) ASSUME_YES=1 ;;
  esac
  shift
done

echo "Starting XFCE Terminal themes uninstaller..."

mkdir -p "$TARGET_DIR"
REMOVED=0
for name in $THEMES_FILES; do
  if [ -f "$TARGET_DIR/$name" ]; then
    rm -f "$TARGET_DIR/$name"
    REMOVED=$((REMOVED+1))
  fi
done
echo "Removed $REMOVED theme files from $TARGET_DIR"

if [ -d "$TARGET_DIR" ] && [ -z "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
  rmdir "$TARGET_DIR" || true
  echo "Removed empty directory: $TARGET_DIR"
fi

PM="$(detect_pm)" || PM=""
SUDO="$(sudo_cmd)"

if [ "$ASSUME_YES" = "1" ] || [ "${XFCE_UNINSTALL_TERM:-0}" = "1" ]; then
  REPLY_XFCE="y"
else
  if [ -t 0 ]; then
    printf "Do you also want to uninstall xfce4-terminal? [y/N] "
    read -r REPLY_XFCE
  else
    REPLY_XFCE="n"
  fi
fi

case "$REPLY_XFCE" in
  y|Y)
    if [ -n "$PM" ]; then
      echo "Uninstalling xfce4-terminal with $PM..."
      case "$PM" in
        brew)
          brew uninstall xfce4-terminal || true
          ;;
        apt-get)
          $SUDO apt-get remove --purge -y xfce4-terminal || true
          ;;
        dnf)
          $SUDO dnf remove -y xfce4-terminal || true
          ;;
        xpm|pacman)
          $SUDO "$PM" -Rns --noconfirm xfce4-terminal || true
          ;;
        zypper)
          $SUDO zypper remove -y xfce4-terminal || true
          ;;
        yum)
          $SUDO yum remove -y xfce4-terminal || true
          ;;
        apk)
          $SUDO apk del xfce4-terminal || true
          ;;
        *)
          echo "Unsupported package manager for automatic uninstall"
          ;;
      esac
    else
      echo "No supported package manager found to uninstall xfce4-terminal"
    fi
    ;;
  *)
    echo "Keeping xfce4-terminal installed"
    ;;
esac

echo "XFCE Terminal themes uninstall completed."

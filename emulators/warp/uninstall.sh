#!/usr/bin/env sh
set -e

detect_target() {
  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      echo "$HOME/.warp/themes"
      ;;
    *)
      echo "${XDG_DATA_HOME:-$HOME/.local/share}/warp-terminal/themes"
      ;;
  esac
}

detect_pm() {
  for pm in brew apt-get dnf xpm pacman zypper yum apk; do
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

echo "Starting Warp themes uninstaller..."

TARGET_DIR="$(detect_target)"
mkdir -p "$TARGET_DIR"

NAMES="x madrid lahabana miami paris tokio oslo helsinki berlin london praha bogota"

REMOVED=0
for name in $NAMES; do
  FILE="$TARGET_DIR/$name.yaml"
  if [ -f "$FILE" ]; then
    rm -f "$FILE"
    REMOVED=$((REMOVED+1))
  fi
done
echo "Removed $REMOVED Warp theme files from $TARGET_DIR"

if [ -d "$TARGET_DIR" ] && [ -z "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
  rmdir "$TARGET_DIR" || true
  echo "Removed empty directory: $TARGET_DIR"
fi

PM="$(detect_pm)" || PM=""
SUDO="$(sudo_cmd)"

if [ "$ASSUME_YES" = "1" ] || [ "${WARP_UNINSTALL_TERM:-0}" = "1" ]; then
  REPLY_WARP="y"
else
  if [ -t 0 ]; then
    printf "Do you also want to uninstall Warp? [y/N] "
    read -r REPLY_WARP
  else
    REPLY_WARP="n"
  fi
fi

case "$REPLY_WARP" in
  y|Y)
    if [ -n "$PM" ]; then
      echo "Uninstalling Warp with $PM..."
      case "$PM" in
        brew)
          brew uninstall warp || true
          ;;
        apt-get)
          $SUDO apt-get remove --purge -y warp-terminal || true
          ;;
        dnf)
          $SUDO dnf remove -y warp-terminal || true
          ;;
        xpm|pacman)
          $SUDO "$PM" -Rns --noconfirm warp-terminal || true
          ;;
        zypper)
          $SUDO zypper remove -y warp-terminal || true
          ;;
        yum)
          $SUDO yum remove -y warp-terminal || true
          ;;
        apk)
          $SUDO apk del warp-terminal || true
          ;;
        *)
          echo "Unsupported package manager for automatic uninstall"
          ;;
      esac
    else
      echo "No supported package manager found to uninstall Warp"
    fi
    ;;
  *)
    echo "Keeping Warp installed"
    ;;
esac

echo "Warp themes uninstall completed."

#!/usr/bin/env sh
set -e

DEST_DIR="$HOME/.local/share/org.gnome.Ptyxis/palettes"
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

remove_aliases() {
  RC="$1"
  [ -f "$RC" ] || return 0
  if sed --version >/dev/null 2>&1; then
    sed -i '/^ptyx() {/,/^}/d' "$RC" || true
    sed -i -E '/^alias ptyx[[:alnum:]]\{1,\}=/d' "$RC" || true
  else
    sed -i '' '/^ptyx() {/,/^}/d' "$RC" || true
    sed -i '' -E '/^alias ptyx[[:alnum:]]\{1,\}=/d' "$RC" || true
  fi
}

ASSUME_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) ASSUME_YES=1 ;;
  esac
  shift
done

echo "Starting Ptyxis themes uninstaller..."

remove_aliases "$HOME/.bashrc" || true
remove_aliases "$HOME/.zshrc" || true

mkdir -p "$DEST_DIR"
REMOVED=0
for name in $THEMES_FILES; do
  if [ -f "$DEST_DIR/$name" ]; then
    rm -f "$DEST_DIR/$name"
    REMOVED=$((REMOVED+1))
  fi
done
echo "Removed $REMOVED palette files from $DEST_DIR"

if [ -d "$DEST_DIR" ] && [ -z "$(ls -A "$DEST_DIR" 2>/dev/null)" ]; then
  rmdir "$DEST_DIR" || true
  echo "Removed empty directory: $DEST_DIR"
fi

PM="$(detect_pm)" || PM=""
SUDO="$(sudo_cmd)"

if [ "$ASSUME_YES" = "1" ] || [ "${PTYXIS_UNINSTALL_TERM:-0}" = "1" ]; then
  REPLY_PTYXIS="y"
else
  if [ -t 0 ]; then
    printf "Do you also want to uninstall Ptyxis? [y/N] "
    read -r REPLY_PTYXIS
  else
    REPLY_PTYXIS="n"
  fi
fi

case "$REPLY_PTYXIS" in
  y|Y)
    if [ -n "$PM" ]; then
      echo "Uninstalling Ptyxis with $PM..."
      case "$PM" in
        brew)
          brew uninstall ptyxis || true
          ;;
        apt-get)
          $SUDO apt-get remove --purge -y ptyxis || true
          ;;
        dnf)
          $SUDO dnf remove -y ptyxis || true
          ;;
        xpm|pacman)
          $SUDO "$PM" -Rns --noconfirm ptyxis || true
          ;;
        zypper)
          $SUDO zypper remove -y ptyxis || true
          ;;
        yum)
          $SUDO yum remove -y ptyxis || true
          ;;
        apk)
          $SUDO apk del ptyxis || true
          ;;
        *)
          echo "Unsupported package manager for automatic uninstall"
          ;;
      esac
    else
      echo "No supported package manager found to uninstall Ptyxis"
    fi
    ;;
  *)
    echo "Keeping Ptyxis installed"
    ;;
esac

echo "Ptyxis themes uninstall completed."

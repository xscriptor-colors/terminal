#!/usr/bin/env sh
set -e

TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wezterm"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/colors"
THEMES_FILES="x.toml madrid.toml lahabana.toml miami.toml paris.toml tokio.toml oslo.toml helsinki.toml berlin.toml london.toml praha.toml bogota.toml"

detect_pm() {
  for pm in brew apt-get dnf xpm pacman zypper yum apk flatpak nix-env; do
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
  OS="$(uname -s)"
  if [ "$OS" = "Darwin" ]; then
    sed -i '' '/^weztheme() {/,/^}/d' "$RC" || true
    sed -i '' -E '/^alias wez[[:alnum:]]\{1,\}=/d' "$RC" || true
  else
    sed -i '/^weztheme() {/,/^}/d' "$RC" || true
    sed -i -E '/^alias wez[[:alnum:]]\{1,\}=/d' "$RC" || true
  fi
}

ASSUME_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) ASSUME_YES=1 ;;
  esac
  shift
done

echo "Starting WezTerm themes uninstaller..."

remove_aliases "$HOME/.bashrc" || true
remove_aliases "$HOME/.zshrc" || true

mkdir -p "$TARGET_THEMES_DIR"
REMOVED=0
for name in $THEMES_FILES; do
  if [ -f "$TARGET_THEMES_DIR/$name" ]; then
    rm -f "$TARGET_THEMES_DIR/$name"
    REMOVED=$((REMOVED+1))
  fi
done
echo "Removed $REMOVED theme files from $TARGET_THEMES_DIR"

if [ -d "$TARGET_THEMES_DIR" ] && [ -z "$(ls -A "$TARGET_THEMES_DIR" 2>/dev/null)" ]; then
  rmdir "$TARGET_THEMES_DIR" || true
  echo "Removed empty directory: $TARGET_THEMES_DIR"
fi

PM="$(detect_pm)" || PM=""
SUDO="$(sudo_cmd)"

if [ "$ASSUME_YES" = "1" ] || [ "${WEZTERM_UNINSTALL_TERM:-0}" = "1" ]; then
  REPLY_WEZTERM="y"
else
  if [ -t 0 ]; then
    printf "Do you also want to uninstall WezTerm? [y/N] "
    read -r REPLY_WEZTERM
  else
    REPLY_WEZTERM="n"
  fi
fi

case "$REPLY_WEZTERM" in
  y|Y)
    if [ -n "$PM" ]; then
      echo "Uninstalling WezTerm with $PM..."
      case "$PM" in
        brew)
          brew uninstall wezterm || true
          ;;
        apt-get)
          $SUDO apt-get remove --purge -y wezterm || true
          ;;
        dnf)
          $SUDO dnf remove -y wezterm || true
          ;;
        xpm|pacman)
          $SUDO "$PM" -Rns --noconfirm wezterm || true
          ;;
        zypper)
          $SUDO zypper remove -y wezterm || true
          ;;
        yum)
          $SUDO yum remove -y wezterm || true
          ;;
        apk)
          $SUDO apk del wezterm || true
          ;;
        flatpak)
          flatpak uninstall -y org.wezfurlong.wezterm || true
          ;;
        nix-env)
          nix-env -e wezterm || true
          ;;
        *)
          echo "Unsupported package manager for automatic uninstall"
          ;;
      esac
    else
      if command -v flatpak >/dev/null 2>&1; then
        flatpak uninstall -y org.wezfurlong.wezterm || true
      else
        echo "No supported package manager found to uninstall WezTerm"
      fi
    fi
    ;;
  *)
    echo "Keeping WezTerm installed"
    ;;
esac

echo "WezTerm themes uninstall completed."

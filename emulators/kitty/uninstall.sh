#!/usr/bin/env sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
TARGET_THEMES_DIR="$TARGET_CONFIG_DIR/themes"
TARGET_SHADERS_DIR="$TARGET_CONFIG_DIR/shaders"
MAIN="$TARGET_CONFIG_DIR/kitty.conf"
THEMES_FILES="x.conf madrid.conf lahabana.conf miami.conf paris.conf tokio.conf oslo.conf helsinki.conf berlin.conf london.conf praha.conf bogota.conf"
SHADERS_FILES="x-glow.slang x-trail.pipeline"
detect_pm() {
  for pm in apt-get dnf pacman zypper yum apk brew; do
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
echo "Starting Kitty uninstaller..."
ASSUME_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) ASSUME_YES=1 ;;
  esac
  shift
done
remove_aliases() {
  RC="$1"
  [ -f "$RC" ] || return 0
  sed -i '/^kix() {/,/^}/d' "$RC" || true
  sed -i -E '/^alias kix[a-zA-Z0-9]+=/d' "$RC" || true
}
remove_aliases "$HOME/.bashrc" && echo "Removed aliases from ~/.bashrc" || true
remove_aliases "$HOME/.zshrc" && echo "Removed aliases from ~/.zshrc" || true
mkdir -p "$TARGET_THEMES_DIR"
REMOVED=0
for name in $THEMES_FILES; do
  if [ -f "$TARGET_THEMES_DIR/$name" ]; then
    rm -f "$TARGET_THEMES_DIR/$name"
    REMOVED=$((REMOVED+1))
  fi
done
echo "Removed $REMOVED theme files from $TARGET_THEMES_DIR"
mkdir -p "$TARGET_SHADERS_DIR"
REMOVED_S=0
for name in $SHADERS_FILES; do
  if [ -f "$TARGET_SHADERS_DIR/$name" ]; then
    rm -f "$TARGET_SHADERS_DIR/$name"
    REMOVED_S=$((REMOVED_S+1))
  fi
done
rmdir "$TARGET_SHADERS_DIR" 2>/dev/null || true
echo "Removed $REMOVED_S shader files from $TARGET_SHADERS_DIR"
restore_config_file() {
  FILE="$1"
  [ -f "$FILE" ] || { echo "Config not found: $FILE"; return 0; }
  LATEST="$(ls -1t "$FILE".bak.* 2>/dev/null | head -1 || true)"
  if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
    cp -f "$LATEST" "$FILE"
    echo "Restored backup: $LATEST -> $FILE"
    return 0
  fi
  sed -i -E '/^include[[:space:]]+themes\/(x\.conf|madrid\.conf|lahabana\.conf|miami\.conf|paris\.conf|tokio\.conf|oslo\.conf|helsinki\.conf|berlin\.conf|london\.conf|praha\.conf|bogota\.conf)[[:space:]]*$/d' "$FILE"
  echo "Removed theme include lines from $FILE"
}
restore_config_file "$MAIN"
echo "Kitty uninstall completed."

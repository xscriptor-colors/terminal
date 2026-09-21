#!/usr/bin/env sh
set -e

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

sed_in_place() {
  EXP="$1"
  FILE="$2"
  if sed --version >/dev/null 2>&1; then
    sed -i -E "$EXP" "$FILE"
  else
    sed -i '' -E "$EXP" "$FILE"
  fi
}

remove_aliases() {
  RC="$1"
  [ -f "$RC" ] || return 0
  if sed --version >/dev/null 2>&1; then
    sed -i '/^gtx() {/,/^}/d' "$RC" || true
    sed -i -E '/^alias gtx[[:alnum:]]\{1,\}=/d' "$RC" || true
  else
    sed -i '' '/^gtx() {/,/^}/d' "$RC" || true
    sed -i '' -E '/^alias gtx[[:alnum:]]\{1,\}=/d' "$RC" || true
  fi
}

ASSUME_YES=0
while [ $# -gt 0 ]; do
  case "$1" in
    -y|--yes) ASSUME_YES=1 ;;
  esac
  shift
done

echo "Starting GNOME Terminal themes uninstaller..."

remove_aliases "$HOME/.bashrc" || true
remove_aliases "$HOME/.zshrc" || true

if command -v gsettings >/dev/null 2>&1; then
  CURRENT="$(gsettings get org.gnome.Terminal.ProfilesList list)"
  STRIPPED="$(printf "%s" "$CURRENT" | tr -d '[]' | tr -d "'" | tr -d '"')"
  FIRST=""
  NEW_LIST=""
  echo "$STRIPPED" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | while read -r uuid; do
    case "$uuid" in
      "$UUID_X"|"$UUID_MADRID"|"$UUID_LAHABANA"|"$UUID_MIAMI"|"$UUID_PARIS"|"$UUID_TOKIO"|"$UUID_OSLO"|"$UUID_HELSINKI"|"$UUID_BERLIN"|"$UUID_LONDON"|"$UUID_PRAHA"|"$UUID_BOGOTA")
        ;;
      *)
        if [ -z "$FIRST" ]; then
          FIRST="$uuid"
        fi
        if [ -z "$NEW_LIST" ]; then
          NEW_LIST="'$uuid'"
        else
          NEW_LIST="$NEW_LIST, '$uuid'"
        fi
        ;;
    esac
  done
  if [ -z "$NEW_LIST" ]; then
    gsettings set org.gnome.Terminal.ProfilesList list "[]"
  else
    gsettings set org.gnome.Terminal.ProfilesList list "[$NEW_LIST]"
  fi
  DEFAULT="$(gsettings get org.gnome.Terminal.ProfilesList default | sed "s/'//g")"
  case "$DEFAULT" in
    "$UUID_X"|"$UUID_MADRID"|"$UUID_LAHABANA"|"$UUID_MIAMI"|"$UUID_PARIS"|"$UUID_TOKIO"|"$UUID_OSLO"|"$UUID_HELSINKI"|"$UUID_BERLIN"|"$UUID_LONDON"|"$UUID_PRAHA"|"$UUID_BOGOTA")
      if [ -n "$FIRST" ]; then
        gsettings set org.gnome.Terminal.ProfilesList default "'$FIRST'"
      fi
      ;;
    *)
      ;;
  esac
fi

if command -v dconf >/dev/null 2>&1; then
  for UUID in \
    "$UUID_X" "$UUID_MADRID" "$UUID_LAHABANA" "$UUID_MIAMI" \
    "$UUID_PARIS" "$UUID_TOKIO" "$UUID_OSLO" "$UUID_HELSINKI" "$UUID_BERLIN" "$UUID_LONDON" \
    "$UUID_PRAHA" "$UUID_BOGOTA"
  do
    dconf reset -f "/org/gnome/terminal/legacy/profiles:/:$UUID/" || true
  done
fi

PM="$(detect_pm)" || PM=""
SUDO="$(sudo_cmd)"

if [ "$ASSUME_YES" = "1" ] || [ "${GNOME_UNINSTALL_TERM:-0}" = "1" ]; then
  REPLY_GNOME="y"
else
  if [ -t 0 ]; then
    printf "Do you also want to uninstall GNOME Terminal? [y/N] "
    read -r REPLY_GNOME
  else
    REPLY_GNOME="n"
  fi
fi

case "$REPLY_GNOME" in
  y|Y)
    if [ -n "$PM" ]; then
      echo "Uninstalling GNOME Terminal with $PM..."
      case "$PM" in
        brew)
          echo "GNOME Terminal uninstall via Homebrew is not supported"
          ;;
        apt-get)
          $SUDO apt-get remove --purge -y gnome-terminal || true
          ;;
        dnf)
          $SUDO dnf remove -y gnome-terminal || true
          ;;
        pacman)
          $SUDO pacman -Rns --noconfirm gnome-terminal || true
          ;;
        zypper)
          $SUDO zypper remove -y gnome-terminal || true
          ;;
        yum)
          $SUDO yum remove -y gnome-terminal || true
          ;;
        apk)
          $SUDO apk del gnome-terminal || true
          ;;
        *)
          echo "Unsupported package manager for automatic uninstall"
          ;;
      esac
    else
      echo "No supported package manager found to uninstall GNOME Terminal"
    fi
    ;;
  *)
    echo "Keeping GNOME Terminal installed"
    ;;
esac

echo "GNOME Terminal themes uninstall completed."

#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#000000'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#f7f1ff'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#000000', '#FF4C8B', '#7FFFD4', '#FFD84C', '#00FFA8', '#D36CFF', '#47CFFF', '#f7f1ff', '#69676c', '#FF4C8B', '#7FFFD4', '#FFD84C', '#00FFA8', '#D36CFF', '#47CFFF', '#f7f1ff']"

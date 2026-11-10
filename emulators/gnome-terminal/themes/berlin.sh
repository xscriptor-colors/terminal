#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#000000'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#cccccc'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#000000', '#999999', '#bbbbbb', '#dddddd', '#888888', '#aaaaaa', '#cccccc', '#ffffff', '#333333', '#bbbbbb', '#dddddd', '#ffffff', '#aaaaaa', '#cccccc', '#eeeeee', '#ffffff']"

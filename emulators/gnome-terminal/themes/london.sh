#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#ffffff'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#333333'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#ffffff', '#333333', '#444444', '#555555', '#666666', '#777777', '#888888', '#333333', '#333333', '#444444', '#555555', '#666666', '#777777', '#888888', '#999999', '#aaaaaa']"

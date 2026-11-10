#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#1a1a1a'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#ffffff'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#1A1A1A', '#FF5555', '#B8E6A0', '#FFE4A3', '#BD93F9', '#FF9AA2', '#8BE9FD', '#FFFFFF', '#6272A4', '#FF6E6E', '#B8E6A0', '#FFE4A3', '#D6ACFF', '#FF9AA2', '#A4FFFF', '#FFFFFF']"

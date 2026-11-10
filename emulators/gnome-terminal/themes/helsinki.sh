#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#f8fafe'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#544d40'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#f8fafe', '#1faa9e', '#733d9a', '#2e70ad', '#b55a0f', '#3e9d21', '#bd4c3d', '#544d40', '#b0a999', '#009e91', '#5a1f8a', '#0f5ba2', '#b23b00', '#218c00', '#b32e1f', '#000000']"

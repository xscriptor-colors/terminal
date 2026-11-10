#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#fafafa'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#1a1a1a'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#fafafa', '#990026', '#007a28', '#8a6408', '#007a9e', '#4d2699', '#007a9e', '#1a1a1a', '#4d4d4d', '#990026', '#007a28', '#8a6408', '#007a9e', '#4d2699', '#007a9e', '#1a1a1a']"

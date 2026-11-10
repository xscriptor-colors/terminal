#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#1a0a30'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#f7f1ff'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#1a0a30', '#fc618d', '#7bd88f', '#fce566', '#a3f3ff', '#c4bdff', '#a3f3ff', '#1a0a30', '#c4bdff', '#fc618d', '#7bd88f', '#fce566', '#a3f3ff', '#c4bdff', '#a3f3ff', '#f7f1ff']"

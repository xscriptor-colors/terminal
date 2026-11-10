#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#19191a'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#f7f1ff'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#19191a', '#fc618d', '#7bd88f', '#e5ff9d', '#fd9353', '#948ae3', '#5ad4e6', '#f7f1ff', '#19191a', '#fc618d', '#7bd88f', '#e5ff9d', '#fd9353', '#948ae3', '#5ad4e6', '#f7f1ff']"

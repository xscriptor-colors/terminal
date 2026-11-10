#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#050505'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#f7f1ff'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#0a0a0a', '#fc618d', '#7bd88f', '#fce566', '#fd9353', '#948ae3', '#5ad4e6', '#f7f1ff', '#0f0f0f', '#fc618d', '#7bd88f', '#fce566', '#fd9353', '#948ae3', '#5ad4e6', '#f7f1ff']"

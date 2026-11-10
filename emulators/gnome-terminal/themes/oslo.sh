#!/usr/bin/env sh
PROFILE_ID="$(dconf read /org/gnome/terminal/legacy/profiles:/default | tr -d "'")"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/use-theme-colors "false"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/background-color "'#3f4451'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/foreground-color "'#abb2bf'"
dconf write /org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/palette "['#3f4451', '#e05561', '#8cc265', '#d18f52', '#4aa5f0', '#c162de', '#42b3c2', '#e6e6e6', '#4f5666', '#ff616e', '#a5e075', '#f0a45d', '#4dc4ff', '#de73ff', '#4cd1e0', '#ffffff']"

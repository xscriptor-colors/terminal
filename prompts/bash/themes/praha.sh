# shellcheck shell=bash
# praha — Bash/Zsh PS1 theme
# Generated from colors.md — canonical mapping
# Source this file in your shell rc to apply.

# Foreground (text) colour helper: 24-bit true colour escape
__x_fg() { printf '\[\e[38;2;%d;%d;%dm\]' "$1" "$2" "$3"; }
__x_reset() { printf '\[\e[0m\]'; }

# Palette
x_user_fg=$(__x_fg 255 228 163)
x_host_fg=$(__x_fg 255 255 255)
x_dir_fg=$(__x_fg 139 233 253)
x_git_fg=$(__x_fg 255 255 255)
x_time_fg=$(__x_fg 255 85 85)
x_ok_fg=$(__x_fg 184 230 160)
x_err_fg=$(__x_fg 255 85 85)
x_dim_fg=$(__x_fg 98 114 164)

# Git branch helper (zsh)
__x_git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null || return
}

# Prompt (Bash)
if [ -n "$BASH_VERSION" ]; then
  PROMPT_COMMAND='__x_ps1=$?'
  PS1='$(x_fg='$x_user_fg'; x_reset='$(__x_reset)'; \
    printf "%s%s" "$x_fg" "\\u"; printf "%s" "$x_reset"; \
    printf "@"; \
    printf "%s%s" "$x_host_fg" "\\h"; printf "%s" "$x_reset"; \
    printf " "; \
    printf "%s%s" "$x_dir_fg" "\\w"; printf "%s" "$x_reset"; \
    printf " "; \
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); \
    if [ -n "$branch" ]; then \
      printf "%s%s" "'$x_git_fg'" "$branch"; printf "%s" "'$(__x_reset)'"; \
      printf " "; \
    fi; \
    if [ "$__x_ps1" -eq 0 ]; then \
      printf "%s" "'$x_ok_fg'"; \
    else \
      printf "%s" "'$x_err_fg'"; \
    fi; \
    printf "❯ "; \
    printf "%s" "'$(__x_reset)'")'

# Prompt (Zsh)
elif [ -n "$ZSH_VERSION" ]; then
  setopt prompt_subst
  precmd() { __x_ps1=$?; }
  PS1='$x_user_fg%n$(__x_reset)@$x_host_fg%m$(__x_reset) $x_dir_fg%(5~|%-1~/…/%3~|%3~)$(__x_reset) $(__x_git_branch)$x_git_fg$(__x_git_branch)$(__x_reset)%(?.$x_ok_fg.$x_err_fg)❯ $(__x_reset)'
fi

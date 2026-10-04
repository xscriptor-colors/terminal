# Xscriptor Kitty Themes

## Files
- `config`: Base Kitty configuration that includes `themes/x.conf` and other defaults.
- `install.sh`: Installs themes and configuration, ensures dependencies, and adds shell aliases for fast theme switching.
- `themes/*.conf`: Theme files ready to be used by Kitty:
  - `x.conf`
  - `madrid.conf`
  - `lahabana.conf`
  - `miami.conf`
  - `paris.conf`
  - `tokio.conf`
  - `oslo.conf`
  - `helsinki.conf`
  - `berlin.conf`
  - `london.conf`
  - `praha.conf`
  - `bogota.conf`
- `shaders/`: Custom cursor trail shader and its pipeline:
  - `x-glow.slang`: neon afterglow drawn while typing and jumping between lines.
  - `x-trail.pipeline`: composes the stock trail, the afterglow and sparks.

## Requirements
- Kitty installed.
- Kitty 0.49.0 or newer and `shader-slang` (provides `slangc`) for the custom trail shader. On Arch: `sudo pacman -S shader-slang`; on other systems install it from your package manager or https://github.com/shader-slang/slang/releases. The installer tries to install it automatically with pacman.
- `sed`, `bash` or `zsh`.
- `fontconfig` (`fc-list`), `curl` or `wget`, `unzip`.
- A Nerd Font installed, specifically `Hack Nerd Font` (installer tries to install it automatically).

## Installation
- One-liner:
```bash
wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/kitty/install.sh | bash
```

or

- Download the repo, go to the folder and run the installer:
  - `chmod +x install.sh && ./install.sh`
- What the installer does:
  - Detects your package manager and installs any missing dependencies (`kitty`, `sed`, `fontconfig`, `curl/wget`, `unzip`).
  - Installs `shader-slang` (custom shader compiler) automatically with pacman, or warns you how to install it on other systems.
  - Installs `Hack Nerd Font` automatically (Homebrew on macOS; download + extract on Linux).
  - Copies all themes to `~/.config/kitty/themes`.
  - Copies the custom shaders to `~/.config/kitty/shaders`.
- Writes `~/.config/kitty/kitty.conf` and includes `themes/x.conf` by default.
- Adds aliases to your shell for quick theme switching.

## Uninstall
- Remote one‑liner:
```bash
wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/kitty/uninstall.sh | bash
# or
curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/kitty/uninstall.sh | bash
```
- Local:
```bash
chmod +x uninstall.sh && ./uninstall.sh
```

## Default Config
- Includes `themes/x.conf` by default.
- Hides window decorations and tab bar; minimal borders.
- Sets background opacity to `0.85` with dynamic opacity enabled.
- Window padding set to `30`.
- Font family `Hack Nerd Font` with `font_size 8.0`.
- Custom neon cursor trail enabled with `custom_shaders x-trail` (requires `cursor_trail 12` and `slangc`).
- Window size and maximize state are not remembered between launches (`remember_window_size no`, `remember_window_position no`), using `1100x650` as initial size.
- Mouse and clipboard:
  - `copy_on_select yes`
  - Clipboard control enabled for primary and system clipboard.
  - Mouse mappings for select/word/line, paste from selection/clipboard.
- URL handling:
  - `detect_urls yes`, `open_url_with default`, `url_style curly`.

## Aliases
- The installer adds shell aliases to switch quickly:
  - `kixx`, `kixmadrid`, `kixlahabana`, `kixmiami`, `kixparis`, `kixtokio`, `kixoslo`, `kixhelsinki`, `kixberlin`, `kixlondon`, `kixpraha`, `kixbogota`
- Usage:
- `kixx` → sets `include themes/x.conf` in `~/.config/kitty/kitty.conf`
- Make sure to reload your shell:
  - `source ~/.bashrc` or `source ~/.zshrc`
- Reload Kitty configuration:
  - `Ctrl+Shift+F5`

## Notes
- Kitty looks up included files relative to the `kitty.conf` location; themes are expected in `~/.config/kitty/themes`.
- Custom shaders are looked up in `~/.config/kitty/shaders`; edit `x-trail.pipeline` to tune the trail intensity, color and sparks, then reload Kitty. A `slangc` in `PATH` is required (`SLANGC=/path/to/slangc` also works).
- To change font family, run `kitty +list-fonts` and update `font_family` accordingly.
- If theme changes do not apply, ensure the `include themes/<name>.conf` line is present and reload the config.

## Troubleshooting
- Aliases not available:
  - Reload your shell rc file or restart the terminal.
- Font not detected:
  - Re-run the installer or set `font_family` to a Nerd Font you already have; confirm with `kitty +list-fonts`.
- Theme change not visible:
  - Ensure the theme file exists in `~/.config/kitty/themes` and the `include` line references it; reload Kitty or open a new window.
- Custom trail not visible:
  - Install `shader-slang` so `slangc` is in `PATH` (Arch: `sudo pacman -S shader-slang`), then reload Kitty (`Ctrl+Shift+F5`). Without the compiler kitty silently disables custom shaders.
  - Ensure `cursor_trail 12`, `custom_shaders x-trail` and `~/.config/kitty/shaders/x-trail.pipeline` are present.

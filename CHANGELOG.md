# Changelog

All notable changes to Terminal Xscriptor will be documented in this file.

## 2026-10-04

### Added
- Kitty custom neon trail shader (`x-glow.slang` + `x-trail.pipeline`): a brighter version of the stock cursor trail with afterglow and sparks while typing and jumping lines
- Kitty installer now ships the shaders to `~/.config/kitty/shaders` and installs `shader-slang` automatically with pacman

### Changed
- Kitty config now enables `custom_shaders x-trail` and no longer remembers the previous window size/maximize state (`remember_window_size no`, `remember_window_position no`)

## 2026-08-23

- Migrate all customizations to xscriptor-colors

## 2026-07-17

### Added
- `cli/` directory with Helix and OpenCode repos imported via git subtree
- `cli/README.md` entry point for CLI tools
- `cli/claude-code` added
- `cli/gitnapse/` with Xscriptor colour themes for GitNapse and install script

### Changed
- Updated main README with CLI section and content nav entry
- Updated CLI tools badge from 2 to 3

## [1.0.0] - 2026-06-12

### Added
- Initial release with 12 city-themed color schemes (x, madrid, lahabana, miami, paris, tokio, oslo, helsinki, berlin, london, praha, bogota)
- Support for 18+ terminal emulators: Alacritty, Foot, Ghostty, GNOME Terminal, Hyper, iTerm2, Kitty, Konsole, MobaXterm, PowerShell/Windows Terminal, Ptyxis, PuTTY, Terminal.app, Terminator, Termux, Tilix, Warp, WezTerm, XFCE Terminal
- Per-emulator install and uninstall scripts with dependency management
- Universal interactive installer (`emulators/install.sh`)
- Theme builder/generator (`builder/build.py`) with template system
- Shell aliases for quick theme switching in each terminal
- Starship prompt configuration with per-theme variants
- Ghostty CSS gradient border styles per theme
- Hack Nerd Font asset
- GitHub Issues-Roadmap sync action
- ROADMAP.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, SUPPORT.md

### Changed
- Project rebranded from xscriptordev to xscriptor
- Major refactor of directory structure and naming conventions across all emulators
- Updated installation scripts for improved reliability and cross-platform support
- Standardized theme file names across all emulators

### Fixed
- Fixed theme names and references across multiple emulators
- Corrected Konsole theme display issues
- Fixed font download logic in install scripts
- Adjusted Ghostty padding configuration

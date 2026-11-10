# PuTTY Themes (Xscriptor)

This folder provides ready-to-import PuTTY color themes as .reg files. Each file creates a PuTTY “Session” preconfigured with the theme’s colors.

## Files
- Location: `emulators/putty/themes`
- Includes: x, madrid, lahabana, miami, paris, tokio, oslo, helsinki, berlin, london, praha, bogota

## Install
- On Windows, double-click any `.reg` file and allow the merge
- Open PuTTY → Saved Sessions → select the newly added session (e.g. “x”), set Host Name, then Save
- To use it as the global default, you can import the file and then copy values to “Default Settings”, or replace the session name in the `.reg` file with `Default%20Settings` before importing

## Notes
- Import writes to `HKCU\Software\SimonTatham\PuTTY\Sessions`
- Colors are per session; apply to each saved connection you use

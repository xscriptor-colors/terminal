<h1 align="center">Starship</h1>

<p>Starship themes generated from the <a href="../../colors.md">X colour palettes</a> following the <a href="../README.md#canonical-colour-mapping">canonical colour mapping</a>. Pick a theme and point <code>STARSHIP_CONFIG</code> to it, or use the installer below.</p>

<h2>Quick Start</h2>

<pre><code>export STARSHIP_CONFIG="$PWD/prompts/starship/themes/x.toml"

# zsh
eval "$(starship init zsh)"
</code></pre>

<p>Use <a href="./starship.toml">starship.toml</a> as a base config if you want to customise modules manually.</p>

<h2>Remote Install</h2>

<p>This script downloads the full <code>prompts/starship</code> folder (themes and <code>starship.toml</code>), writes the active theme to <code>~/.config/starship.toml</code> and appends one managed block to <code>~/.zshrc</code> or <code>~/.bashrc</code> with the <code>STARSHIP_CONFIG</code> export, helper functions, aliases and a guarded <code>starship init</code>.</p>

<pre><code>curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/prompts/starship/install.sh | bash</code></pre>

<p>Uninstall:</p>

<pre><code>curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/prompts/starship/install.sh | bash -s -- --uninstall</code></pre>

<p>Install path: <code>~/.config/equisdots/starship</code> when equisdots is present, otherwise <code>~/.config/xscriptor/starship</code> (the same roots theme-sync understands). Active config: <code>~/.config/starship.toml</code>.</p>

<p>Installer options:</p>

<pre><code>install.sh --theme tokio     # theme to install (default: x)
install.sh --sync            # run equisdots theme-sync (starship target) afterwards
install.sh --print           # print the managed block (stow/chezmoi) without writing
install.sh --no-init         # do not add `starship init` to the shell config
install.sh --uninstall       # remove the managed block and generated files</code></pre>

<p>The installer is non-destructive: it replaces only its managed block, preserves symlinked dotfiles (editing the real target), keeps a one-time <code>.xscriptor-starship.bak</code> backup, never overwrites a <code>~/.config/starship.toml</code> you own (one without the theme-sync marker) and removes old <code>xscriptor-starship-v2</code> blocks when upgrading. Re-running it is idempotent.</p>

<p>The <code>starship</code> binary is not installed by this script. Install it from <a href="https://starship.rs/guide/">starship.rs</a>; the managed block skips <code>starship init</code> until the binary exists.</p>

<p>After install, switch themes with:</p>

<pre><code>xscriptor_starship_theme tokio</code></pre>

<p>Short aliases are also available:</p>

<pre><code>ssx
ssberlin
ssbogota
ssbase</code></pre>

<p><strong>tokio</strong> splits information across left and right prompts (native in zsh; bash requires ble.sh v0.4+).</p>

<p>When the active file is managed, the helper rewrites <code>~/.config/starship.toml</code> and the change applies on the next prompt. If you own that file, the helper updates the <code>STARSHIP_CONFIG</code> export instead.</p>

<p><strong>equisdots / theme-sync:</strong> the starship target already understands the xscriptor/equisdots theme roots, the fixed <code>~/.config/starship.toml</code> and both auto-generated markers. The installer follows that contract, so palette changes regenerate the active config for every open shell and running the installer again does not break the next sync. <code>--sync</code> applies the current palette immediately. If <code>~/.config/starship.toml</code> is your own config, theme-sync keeps it and switches through the per-palette themes; the installer does the same. theme-sync may report the portable <code>$HOME/...</code> export as custom; it still updates the active file.</p>

<p>Optional environment variables:</p>

<ul>
  <li><code>XSC_STARSHIP_DIR</code> (install location)</li>
  <li><code>XSC_STARSHIP_THEME</code> (default theme, same as <code>--theme</code>)</li>
  <li><code>XSC_STARSHIP_REF</code> (git ref, default: main)</li>
  <li><code>XSC_STARSHIP_SHELL_RC</code> (shell config file)</li>
  <li><code>XSC_STARSHIP_SOURCE_DIR</code> (local <code>prompts/starship</code> directory, skips the download)</li>
</ul>

<h2>Themes</h2>

<table>
  <tr>
    <th align="left">Theme</th>
    <th align="left">Config</th>
    <th align="left">Layout</th>
  </tr>
  <tr><td>x</td><td><a href="./themes/x.toml">x.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>madrid</td><td><a href="./themes/madrid.toml">madrid.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>lahabana</td><td><a href="./themes/lahabana.toml">lahabana.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>miami</td><td><a href="./themes/miami.toml">miami.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>paris</td><td><a href="./themes/paris.toml">paris.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>tokio</td><td><a href="./themes/tokio.toml">tokio.toml</a></td><td>left + right prompts</td></tr>
  <tr><td>oslo</td><td><a href="./themes/oslo.toml">oslo.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>helsinki</td><td><a href="./themes/helsinki.toml">helsinki.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>berlin</td><td><a href="./themes/berlin.toml">berlin.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>london</td><td><a href="./themes/london.toml">london.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>praha</td><td><a href="./themes/praha.toml">praha.toml</a></td><td>single-line + prompt char</td></tr>
  <tr><td>bogota</td><td><a href="./themes/bogota.toml">bogota.toml</a></td><td>single-line + prompt char</td></tr>
</table>

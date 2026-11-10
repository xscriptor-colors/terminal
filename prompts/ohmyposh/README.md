<h1 align="center">Oh My Posh</h1>

<p>Oh My Posh themes generated from the <a href="../../colors.md">X colour palettes</a> following the same canonical colour mapping as the Starship themes.</p>

<h2>Quick Start</h2>

<pre><code>export POSH_THEMES_PATH="$PWD/prompts/ohmyposh/themes"

# zsh
eval "$(oh-my-posh init zsh --config "$PWD/prompts/ohmyposh/themes/x.json")"
</code></pre>

<h2>Remote Install</h2>

<p>This script downloads the full <code>prompts/ohmyposh</code> folder (themes) and adds a helper function to your shell config.</p>

<pre><code>curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/prompts/ohmyposh/install.sh | bash</code></pre>

<p>Uninstall:</p>

<pre><code>curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/prompts/ohmyposh/install.sh | bash -s -- --uninstall</code></pre>

<p>Install path (default): <code>~/.config/xscriptor/ohmyposh</code></p>

<p>After install, switch themes with:</p>

<pre><code>xscriptor_ohmyposh_theme tokio</code></pre>

<p>Short aliases are also available:</p>

<pre><code>opx
opberlin
opbogota
opbase</code></pre>

<h2>Themes</h2>

<table>
  <tr>
    <th align="left">Theme</th>
    <th align="left">Config</th>
  </tr>
  <tr><td>x</td><td><a href="./themes/x.json">x.json</a></td></tr>
  <tr><td>madrid</td><td><a href="./themes/madrid.json">madrid.json</a></td></tr>
  <tr><td>lahabana</td><td><a href="./themes/lahabana.json">lahabana.json</a></td></tr>
  <tr><td>miami</td><td><a href="./themes/miami.json">miami.json</a></td></tr>
  <tr><td>paris</td><td><a href="./themes/paris.json">paris.json</a></td></tr>
  <tr><td>tokio</td><td><a href="./themes/tokio.json">tokio.json</a></td></tr>
  <tr><td>oslo</td><td><a href="./themes/oslo.json">oslo.json</a></td></tr>
  <tr><td>helsinki</td><td><a href="./themes/helsinki.json">helsinki.json</a></td></tr>
  <tr><td>berlin</td><td><a href="./themes/berlin.json">berlin.json</a></td></tr>
  <tr><td>london</td><td><a href="./themes/london.json">london.json</a></td></tr>
  <tr><td>praha</td><td><a href="./themes/praha.json">praha.json</a></td></tr>
  <tr><td>bogota</td><td><a href="./themes/bogota.json">bogota.json</a></td></tr>
</table>

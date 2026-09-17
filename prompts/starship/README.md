<h1 align="center">Starship</h2>

<p>Starship themes generated from the <a href="../colors.md">X colour palettes</a> following the <a href="../README.md#canonical-colour-mapping">canonical colour mapping</a>. Pick a theme and point <code>STARSHIP_CONFIG</code> to it.</p>

<h2>Quick Start</h2>

<pre><code>export STARSHIP_CONFIG="$PWD/prompts/starship/themes/x.toml"

# zsh
eval "$(starship init zsh)"
</code></pre>

<p>Use <a href="./starship.toml">starship.toml</a> as a base config if you want to customise modules manually.</p>

<h2>Remote Install</h2>

<p>This script downloads the full <code>prompts/starship</code> folder (themes and <code>starship.toml</code>) and adds a helper function to your shell config.</p>

<pre><code>curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/prompts/starship/install.sh | bash</code></pre>

<p>Uninstall:</p>

<pre><code>curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/prompts/starship/install.sh | bash -s -- --uninstall</code></pre>

<p>Install path (default): <code>~/.config/xscriptor/starship</code></p>

<p>After install, switch themes with:</p>

<pre><code>xscriptor_starship_theme tokio</code></pre>

<p>Short aliases are also available:</p>

<pre><code>ssx
ssberlin
ssbogota
ssbase</code></pre>

<p><strong>tokio</strong> splits information across left and right prompts (native in zsh; bash requires ble.sh v0.4+).</p>

<p>The function updates the line below in your shell config to point at the selected theme:</p>

<pre><code>export STARSHIP_CONFIG="/path/to/starship/themes/x.toml"</code></pre>

<p>Optional environment variables:</p>

<ul>
  <li><code>XSC_STARSHIP_DIR</code> (install location)</li>
  <li><code>XSC_STARSHIP_REF</code> (git ref, default: main)</li>
  <li><code>XSC_STARSHIP_SHELL_RC</code> (shell config file)</li>
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

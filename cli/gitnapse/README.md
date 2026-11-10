<h1 align="center">Xscriptor GitNapse</h1>

<p>A collection of colour themes for <a href="https://github.com/xscriptor-colors/terminal/tree/main/cli/gitnapse">GitNapse</a>, the TUI client for GitHub. These schemes are drawn from the Xscriptor palette system and designed to provide a consistent visual experience across all tools.</p>

<h2 align="center">Table of Contents</h2>

<ul>
  <li><a href="#themes">Themes</a></li>
  <li><a href="#quick-start">Quick Start</a></li>
  <li><a href="#script-options">Script Options</a></li>
  <li><a href="#selecting-a-theme">Selecting a Theme</a></li>
  <li><a href="#related-documents">Related Documents</a></li>
  <li><a href="#x">X</a></li>
</ul>

<h2 align="center" id="themes">Themes</h2>

<table>
  <thead>
    <tr>
      <th>Theme</th>
      <th>Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>x</code></td>
      <td>Dark</td>
      <td>Deep dark with vibrant pink, green, and cyan accents</td>
    </tr>
    <tr>
      <td><code>madrid</code></td>
      <td>Light</td>
      <td>Clean light with deep red, green, and blue tones</td>
    </tr>
    <tr>
      <td><code>lahabana</code></td>
      <td>Dark</td>
      <td>Dark gray with bright neon accents</td>
    </tr>
    <tr>
      <td><code>miami</code></td>
      <td>Dark</td>
      <td>True black with synthwave-inspired colors</td>
    </tr>
    <tr>
      <td><code>paris</code></td>
      <td>Dark</td>
      <td>Purple-black with pastel cyan and blue</td>
    </tr>
    <tr>
      <td><code>tokio</code></td>
      <td>Dark</td>
      <td>Dark gray with balanced warm and cool tones</td>
    </tr>
    <tr>
      <td><code>oslo</code></td>
      <td>Dark</td>
      <td>Blue-gray with professional muted palette</td>
    </tr>
    <tr>
      <td><code>helsinki</code></td>
      <td>Light</td>
      <td>Near-white with earthy, natural tones</td>
    </tr>
    <tr>
      <td><code>berlin</code></td>
      <td>Dark</td>
      <td>Black with monochrome grayscale palette</td>
    </tr>
    <tr>
      <td><code>london</code></td>
      <td>Light</td>
      <td>White with sophisticated grayscale tones</td>
    </tr>
    <tr>
      <td><code>praha</code></td>
      <td>Dark</td>
      <td>Dark with Dracula-inspired vibrant colors</td>
    </tr>
    <tr>
      <td><code>bogota</code></td>
      <td>Dark</td>
      <td>Maroon-black with cyan and warm accents</td>
    </tr>
  </tbody>
</table>

<h2 align="center" id="quick-start">Quick Start</h2>

<p>Install all themes with curl or wget:</p>

<pre><code>sh -c "$(curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/cli/gitnapse/scripts/install.sh)"</code></pre>

<pre><code>sh -c "$(wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/cli/gitnapse/scripts/install.sh)"</code></pre>

<p>Or run locally from the repo:</p>

<pre><code>bash cli/gitnapse/scripts/install.sh</code></pre>

<h2 align="center" id="script-options">Script Options</h2>

<ul>
  <li><code>--branch &lt;name&gt;</code>: remote branch to use (default: main)</li>
  <li><code>--repo &lt;url&gt;</code>: remote repository URL (default: https://github.com/xscriptor-colors/terminal)</li>
  <li><code>--dry-run</code>: show actions without executing</li>
  <li><code>--force</code>: overwrite existing theme config</li>
  <li><code>--help</code>: show help</li>
</ul>

<h2 align="center" id="selecting-a-theme">Selecting a Theme</h2>

<p>Once installed, set your active theme in <code>~/.config/GitNapse/theme.jsonc</code>:</p>

<pre><code>{
    // GitNapse Theme
    "theme_name": "x"
}
</code></pre>

<p>Replace <code>"x"</code> with any theme name from the table above (e.g., <code>"tokio"</code>, <code>"oslo"</code>, <code>"berlin"</code>).</p>

<p>You can also switch themes at runtime: open the command palette (<code>Ctrl+P</code>) and select <strong>Change Theme</strong>. Your choice is persisted automatically.</p>

<h2 align="center" id="related-documents">Related Documents</h2>

<ul>
  <li><a href="https://github.com/xscriptor-colors/terminal/tree/main/cli/gitnapse">GitNapse Repository</a> - The TUI client for GitHub</li>
  <li><a href="../../colors.md">Colors</a> - Full Xscriptor colour palette reference</li>
</ul>

<div id="x" align="center">
<h2>X</h2>

<a href="https://xscriptor.io">Dev</a>
 & 
<a href="https://github.com/xscriptor">Github</a>
 & 
<a href="https://www.xscriptor.com">X</a>

</div>

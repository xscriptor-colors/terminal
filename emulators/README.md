<h1 align="center">Emulators</h1>

<p>This section contains the terminal emulator themes, installers, and per-terminal setup notes. Use the universal installer for a guided setup, or jump straight to a specific terminal below.</p>

<h2 align="center">Universal Installer</h2>

<pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/install.sh | bash
# or, on systems with curl:
curl -fsSL https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/install.sh | bash</code></pre>

<p>Windows-only terminals (PowerShell, MobaXterm, PuTTY) use their own install or import steps. See each terminal README for details.</p>

<details>
  <summary>View Installation Instructions for Supported Terminals</summary>

  <ul>
    <li>
      <a href="./alacritty/README.md">Alacritty</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/alacritty/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./foot/README.md">Foot</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/foot/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./ghostty/README.md">Ghostty</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/ghostty/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./gnome-terminal/README.md">GNOME Terminal</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/gnome-terminal/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./hyper/README.md">Hyper</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/hyper/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./iterm/README.md">iTerm2</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/iterm/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./kitty/README.md">Kitty</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/kitty/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./konsole/README.md">Konsole</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/konsole/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./mobaxterm/README.md">MobaXterm (Windows)</a>
    </li>
    <li>
      <a href="./powershell/README.md">PowerShell (Windows)</a>
      <br>
      Remote install (Windows PowerShell 5.1):
      <pre><code>[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force
iex (iwr 'https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/powershell/install.ps1' -UseBasicParsing).Content</code></pre>
      Remote install (PowerShell 7+):
      <pre><code>Set-ExecutionPolicy Bypass -Scope Process -Force
irm 'https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/powershell/install.ps1' -Raw | iex</code></pre>
      Default one-liner:
      <pre><code>Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/powershell/install.ps1 | iex</code></pre>
    </li>
    <li>
      <a href="./ptyxis/README.md">Ptyxis</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/ptyxis/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./putty/README.md">PuTTY (Windows)</a>
    </li>
    <li>
      <a href="./terminal.app/README.md">Terminal.app (macOS)</a>
    </li>
    <li>
      <a href="./terminator/README.md">Terminator</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/terminator/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./termux/README.md">Termux (Android)</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/termux/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./tilix/README.md">Tilix</a>
    </li>
    <li>
      <a href="./warp/README.md">Warp</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/warp/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./wezterm/README.md">WezTerm</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/wezterm/install.sh | bash</code></pre>
    </li>
    <li>
      <a href="./xfce/README.md">XFCE Terminal</a>
      <pre><code>wget -qO- https://raw.githubusercontent.com/xscriptor-colors/terminal/main/emulators/xfce/install.sh | bash</code></pre>
    </li>
  </ul>
  <p>Note: In some directories you will find an <code>install.sh</code> script you can run to simplify theme installation for the terminal you use.</p>
</details>

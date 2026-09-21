param(
  [switch]$Force
)
$paths = @("$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json", "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json")
$settingsPath = $null
foreach ($p in $paths) { if (Test-Path $p) { $settingsPath = $p; break } }
if ($settingsPath) {
  $backups = Get-ChildItem -Path "$settingsPath.bak.*" -ErrorAction SilentlyContinue
  if ($backups -and -not $Force) {
    $latest = $backups | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latest) {
      Copy-Item $latest.FullName $settingsPath -Force
      Write-Host "Restored Windows Terminal settings from backup: $($latest.Name)"
    }
  } else {
    try {
      $json = Get-Content $settingsPath -Raw | ConvertFrom-Json
      $schemeNames = @(
        "Xscriptor",
        "Xscriptor Light",
        "X Candy Pop",
        "X Nord",
        "X Nord Inverted",
        "X Greyscale",
        "X Greyscale Inverted",
        "X Sense",
        "X Persecution",
        "X Dark One",
        "X Dark Colors"
      )
      if ($null -ne $json.schemes) {
        $json.schemes = @($json.schemes | Where-Object { $schemeNames -notcontains $_.name })
      }
      $profilesList = $null
      if ($json.profiles -is [System.Collections.IDictionary] -and $json.profiles.ContainsKey("list")) {
        $profilesList = $json.profiles.list
      } elseif ($json.profiles -is [System.Collections.IEnumerable]) {
        $profilesList = $json.profiles
      }
      if ($profilesList) {
        foreach ($profile in $profilesList) {
          if ($profile.name -match "PowerShell" -and ($profile.PSObject.Properties.Name -contains "colorScheme")) {
            $profile.PSObject.Properties.Remove("colorScheme")
          }
        }
      }
      if ($json.profiles -is [System.Collections.IDictionary]) {
        if ($json.profiles.ContainsKey("defaults") -and $null -ne $json.profiles.defaults) {
          if ($json.profiles.defaults.PSObject.Properties.Name -contains "colorScheme") {
            $json.profiles.defaults.PSObject.Properties.Remove("colorScheme")
          }
        }
      }
      $json | ConvertTo-Json -Depth 20 | Set-Content $settingsPath -Encoding UTF8
      Write-Host "Removed Xscriptor schemes and colorScheme assignments from Windows Terminal."
    } catch {
      Write-Host "Failed to update Windows Terminal settings."
    }
  }
}
$rcTargets = @()
if ($PROFILE) { $rcTargets += $PROFILE }
if ($PROFILE -and $PROFILE -ne $PROFILE.CurrentUserAllHosts) { $rcTargets += $PROFILE.CurrentUserAllHosts }
foreach ($rc in $rcTargets) {
  if (Test-Path $rc) {
    $content = Get-Content $rc -Raw -ErrorAction SilentlyContinue
    if ($content) {
      $content = [regex]::Replace($content, "(?ms)function\s+pwsx\s*\(.*?\)\s*\{.*?\}", "")
      $aliases = @('pwsxx','pwsxmadrid','pwsxlahabana','pwsxmiami','pwsxparis','pwsxtokio','pwsxoslo','pwsxhelsinki','pwsxberlin','pwsxlondon','pwsxpraha','pwsxbogota')
      foreach ($a in $aliases) {
        $content = [regex]::Replace($content, "(?ms)function\s+$a\s*\{.*?\}", "")
      }
      Set-Content -Path $rc -Value $content -Encoding UTF8
      Write-Host "Removed PowerShell functions and aliases from profile: $rc"
    }
  }
}
Write-Host "Uninstall completed."

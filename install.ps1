<#
.SYNOPSIS
  Installs Socratic mode globally (user-level, not per project) on Windows.

.EXAMPLE
  .\install.ps1              # both harnesses
  .\install.ps1 claude       # Claude Code only  -> $env:CLAUDE_CONFIG_DIR or ~\.claude
  .\install.ps1 opencode     # OpenCode only     -> $env:XDG_CONFIG_HOME\opencode or ~\.config\opencode

  If scripts are blocked by execution policy, run:
  powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
param(
  [ValidateSet('all', 'claude', 'opencode')]
  [string]$Target = 'all'
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Copy-Tree([string]$From, [string]$To) {
  if (-not (Test-Path -LiteralPath $From)) { throw "Missing source folder: $From" }
  New-Item -ItemType Directory -Force -Path $To | Out-Null
  Get-ChildItem -LiteralPath $From -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($From.Length).TrimStart('\', '/')
    $target = Join-Path $To $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null
    # Keep whatever the person customised before we overwrite it. The socratic skill
    # is skipped because the config path rewritten below makes it differ every run.
    if ((Test-Path -LiteralPath $target) -and ($rel -notlike '*skills\socratic\SKILL.md')) {
      $mine = (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash
      $theirs = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
      if ($mine -ne $theirs) {
        Copy-Item -LiteralPath $target -Destination "$target.bak" -Force
        Write-Host "  kept your edited $rel as $rel.bak"
      }
    }
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
  }
}

# The two harness copies of each prompt must stay identical apart from frontmatter
# and the harness-specific tail. Editing one and not the other is the easiest way
# to break this repo, so the installer refuses to run on drift.
function Get-PromptBody([string]$Path, [string]$CutAt) {
  $lines = [System.IO.File]::ReadAllText($Path) -split "`r?`n"
  $body = New-Object System.Collections.Generic.List[string]
  $inFront = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($i -eq 0 -and $line -eq '---') { $inFront = $true; continue }
    if ($inFront) { if ($line -eq '---') { $inFront = $false }; continue }
    if ($CutAt -and $line -eq $CutAt) { break }
    $body.Add($line)
  }
  while ($body.Count -gt 0 -and $body[$body.Count - 1].Trim() -eq '') { $body.RemoveAt($body.Count - 1) }
  return ,$body.ToArray()
}

function Assert-PromptsInSync([string]$Left, [string]$Right, [string]$CutAt) {
  $a = Get-PromptBody $Left $CutAt
  $b = Get-PromptBody $Right $CutAt
  $same = $a.Count -eq $b.Count
  if ($same) {
    for ($i = 0; $i -lt $a.Count; $i++) {
      if ($a[$i] -cne $b[$i]) { $same = $false; break }
    }
  }
  if ($same) {
    Write-Host "  prompt in sync: $([System.IO.Path]::GetFileName($Left))"
    return
  }

  $n = 0
  while ($n -lt $a.Count -and $n -lt $b.Count -and $a[$n] -ceq $b[$n]) { $n++ }
  $mine = if ($n -lt $a.Count) { $a[$n] } else { '<end of body>' }
  $theirs = if ($n -lt $b.Count) { $b[$n] } else { '<end of body>' }
  Write-Host ''
  Write-Host "Prompt copies have drifted (body line $($n + 1)):" -ForegroundColor Red
  Write-Host "  $Left"
  Write-Host "  $Right"
  Write-Host "  - $mine"
  Write-Host "  + $theirs"
  Write-Host 'Prompt copies must stay identical apart from frontmatter and the harness-specific tail.' -ForegroundColor Red
  Write-Host 'Fix both files, then run the installer again.' -ForegroundColor Red
  exit 1
}

Write-Host 'Checking that both harnesses carry the same prompts...'
$claudeSrc = Join-Path $here 'claude-code'
$opencodeSrc = Join-Path $here 'opencode'
Assert-PromptsInSync (Join-Path $claudeSrc 'output-styles\socratic.md') (Join-Path $opencodeSrc 'agents\socratic.md') '## Tools in this harness'
Assert-PromptsInSync (Join-Path $claudeSrc 'agents\socratic-researcher.md') (Join-Path $opencodeSrc 'agents\socratic-researcher.md')
Assert-PromptsInSync (Join-Path $claudeSrc 'skills\reflect\SKILL.md') (Join-Path $opencodeSrc 'commands\reflect.md')

if ($Target -in 'all', 'claude') {
  $dest = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
  Copy-Tree (Join-Path $here 'claude-code') $dest

  # The /socratic skill normally resolves the config dir at load time with a bash
  # injection. On Windows that injection runs in Git Bash by default, but in
  # PowerShell when CLAUDE_CODE_USE_POWERSHELL_TOOL=1, where the bash syntax breaks.
  # Bake in the resolved path instead, so it works with either shell.
  $skill = [System.IO.Path]::Combine($dest, 'skills', 'socratic', 'SKILL.md')
  $text = [System.IO.File]::ReadAllText($skill)
  $text = [regex]::Replace($text, '(?m)^Claude config directory: !`.*`(\r?)$',
    { param($m) "Claude config directory: $dest" + $m.Groups[1].Value })
  [System.IO.File]::WriteAllText($skill, $text, $utf8NoBom)

  Write-Host "Claude Code: installed in $dest (pick 'Socratic' in /config, or type /socratic)"
}

if ($Target -in 'all', 'opencode') {
  $base = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
  $dest = Join-Path $base 'opencode'
  Copy-Tree (Join-Path $here 'opencode') $dest
  Write-Host "OpenCode: installed in $dest (press Tab to switch to 'socratic')"
  if (-not $env:OPENCODE_ENABLE_EXA) {
    Write-Host "  Note: OpenCode's websearch needs OPENCODE_ENABLE_EXA=1 unless you use OpenCode Zen models."
    Write-Host "  To set it permanently: setx OPENCODE_ENABLE_EXA 1   (then open a new terminal)"
  }
}

New-Item -ItemType Directory -Force -Path (Join-Path $HOME 'socratic-journal') | Out-Null

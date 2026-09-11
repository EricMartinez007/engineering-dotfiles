# Installs Eric's Claude Code agents and skills into ~\.claude\ on Windows.
# Safe to re-run: if a file already exists and differs, it's backed up to <file>.bak first.
#
# Usage (from the repo root):
#   powershell -ExecutionPolicy Bypass -File .\install.ps1

$ErrorActionPreference = "Stop"

$src  = Join-Path $PSScriptRoot "claude"
$dest = Join-Path $HOME ".claude"

Write-Host "Installing Claude config from: $src"
Write-Host "                          into: $dest"
Write-Host ""

Get-ChildItem -Path $src -Recurse -File | ForEach-Object {
    $rel      = $_.FullName.Substring($src.Length + 1)   # path relative to claude\
    $destFile = Join-Path $dest $rel
    $destDir  = Split-Path $destFile -Parent
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null

    if ((Test-Path $destFile) -and
        (Get-FileHash $_.FullName).Hash -ne (Get-FileHash $destFile).Hash) {
        Copy-Item $destFile "$destFile.bak" -Force
        Write-Host "  backed up existing -> $destFile.bak"
    }
    Copy-Item $_.FullName $destFile -Force
    Write-Host "  installed $destFile"
}

# Seed a personal learner profile the first time so the teacher agent has someone
# to calibrate to. Never overwrite an existing one -- it's yours to edit.
$profilePath  = Join-Path $dest "learner-profile.md"
$templatePath = Join-Path $PSScriptRoot "learner-profile.example.md"
if ((-not (Test-Path $profilePath)) -and (Test-Path $templatePath)) {
    Copy-Item $templatePath $profilePath
    Write-Host "  created $profilePath -- edit it to personalize the teacher agent"
}

Write-Host ""
Write-Host "Done. Restart Claude Code (or run /agents) to pick up the changes."

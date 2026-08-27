# memoryboost - sync project dossiers to each project root (AGENTS.md)
# Usage: powershell -ExecutionPolicy Bypass -File scripts/sync-project-agents.ps1 [-MapFile sync-map.json] [-DryRun]
# Rules:
#   1) Copy projects/<dossier>.md to <project-root>/AGENTS.md (overwrite)
#   2) Create <project-root>/CLAUDE.md with "@AGENTS.md" ONLY if it does not exist
#      (existing CLAUDE.md is never touched - review manually)
# Map file (JSON): { "dossier-file.md": "path/to/project-root" }
#   - dossier path resolves to <map-file-dir>/projects/<dossier-file.md>
#   - project path resolves relative to the map file dir (absolute paths allowed)
# NOTE: keep this script pure ASCII - Windows PowerShell 5.1 misparses UTF-8 no-BOM scripts with CJK comments

param(
  [string]$MapFile = 'sync-map.json',
  [switch]$DryRun
)

$mapPath = $MapFile
if (-not [System.IO.Path]::IsPathRooted($mapPath)) {
  $mapPath = Join-Path (Get-Location) $MapFile
}
if (-not (Test-Path -Path $mapPath)) { Write-Host "ERROR map file not found: $mapPath"; exit 1 }

$mapDir = Split-Path -Parent $mapPath
$map = Get-Content -Path $mapPath -Raw | ConvertFrom-Json
$utf8 = New-Object System.Text.UTF8Encoding($false)
$count = 0

foreach ($prop in $map.psobject.Properties) {
  $dossier = Join-Path (Join-Path $mapDir 'projects') $prop.Name
  $destDir = [System.IO.Path]::GetFullPath((Join-Path $mapDir $prop.Value))
  if (-not (Test-Path -Path $dossier)) { Write-Host "SKIP dossier missing: $dossier"; continue }
  if (-not (Test-Path -Path $destDir)) { Write-Host "SKIP project dir missing: $destDir"; continue }

  $agentsPath = Join-Path $destDir 'AGENTS.md'
  $claudePath = Join-Path $destDir 'CLAUDE.md'

  if ($DryRun) {
    Write-Host "[DRY-RUN] copy $dossier -> $agentsPath"
    if (Test-Path -Path $claudePath) { Write-Host "[DRY-RUN] CLAUDE.md exists, would skip: $claudePath" }
    else { Write-Host "[DRY-RUN] would create CLAUDE.md (@AGENTS.md): $claudePath" }
    $count++
    continue
  }

  Copy-Item -Path $dossier -Destination $agentsPath -Force
  Write-Host "OK   AGENTS.md <- $($prop.Name)  ->  $destDir"
  if (Test-Path -Path $claudePath) {
    Write-Host "SKIP CLAUDE.md exists (manual review): $claudePath"
  } else {
    [System.IO.File]::WriteAllText($claudePath, '@AGENTS.md', $utf8)
    Write-Host "OK   CLAUDE.md (new: @AGENTS.md)  ->  $destDir"
  }
  $count++
}

Write-Host "Done. Processed $count dossier(s)."

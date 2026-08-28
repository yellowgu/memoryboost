# memoryboost deploy - one-command setup of your private AI-agent memory library
# Usage:
#   irm https://gitee.com/yellowgu/memoryboost/raw/main/scripts/deploy.ps1 -OutFile deploy.ps1; .\deploy.ps1
# Behavior (light interactive, 3 questions max):
#   1) library path (Enter = D:\memory)
#   2) your alias for AGENTS.md
#   3) create a dossier for the current directory? [Y/n]
# Everything else is left as template placeholders for you to fill in later.
# Unattended bypass (automated tests / remote setup):
#   $env:MB_LIB_DIR='D:\memory'; $env:MB_USER_ID='me'; $env:MB_PROJECT_YES='1'; .\deploy.ps1
# NOTE: keep this file UTF-8 with BOM - PowerShell 5.1 misparses no-BOM UTF-8 (CJK garbled)

$ErrorActionPreference = 'Stop'

function Say($s)  { Write-Host $s }
function Tip($s)  { Write-Host ('  [说明] ' + $s) -ForegroundColor DarkGray }
function Ok($s)   { Write-Host ('  [通过] ' + $s) -ForegroundColor Green }
function Warn($s) { Write-Host ('  [警告] ' + $s) -ForegroundColor Yellow }

Say '================================================================'
Say '  memoryboost deploy V1.0.0 —— AI Agent 记忆架构一键部署'
Say '  源码可见：https://gitee.com/yellowgu/memoryboost  （GitHub 镜像同名仓库）'
Say '================================================================'
Tip '本脚本将：下载模板与同步脚本 → 建立你的私有记忆库 → 生成全局记忆文件 → （可选）为当前目录建档并同步'
Tip '只问 2-3 个问题；所有内容只写入你的本机目录，不上传任何信息。'

# ---------- 1/7 环境检测 ----------
Say '[步骤] 1/7 环境检测'
if ($PSVersionTable.PSVersion.Major -lt 5) { Say '本脚本需要 PowerShell 5.0+（Win10/11 自带）。当前版本过低，无法继续。'; exit 1 }
Ok ('PowerShell ' + $PSVersionTable.PSVersion.ToString())

# ---------- 2/7 记忆库位置 ----------
Say '[步骤] 2/7 记忆库位置'
if ($env:MB_LIB_DIR) {
  $libDir = $env:MB_LIB_DIR.TrimEnd('\')
  Tip ('MB_LIB_DIR 已指定，跳过询问：' + $libDir)
} else {
  $ans = Read-Host '记忆库建在哪里？（回车 = D:\memory）'
  $libDir = if ($ans) { $ans } else { 'D:\memory' }
  $libDir = $libDir.TrimEnd('\')
}
if (-not (Test-Path $libDir)) { New-Item -ItemType Directory -Force $libDir | Out-Null }
Ok ('记忆库：' + $libDir)

# ---------- 3/7 下载模板与同步脚本 ----------
Say '[步骤] 3/7 下载模板与同步脚本'
Tip '从 Gitee 下载模板与同步脚本（无需安装 git）……'
# 文件清单与仓库保持同步：仓库新增模板/脚本文件时，必须在此追加
$base = 'https://gitee.com/yellowgu/memoryboost/raw/main/'
$files = @(
  'templates/AGENTS.template.md',
  'templates/project.template.md',
  'templates/HANDOFF.template.md',
  'templates/spec.template.md',
  'scripts/sync-project-agents.ps1'
)
$tmp = Join-Path $env:TEMP 'memoryboost-files'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Force $tmp | Out-Null
try {
  foreach ($f in $files) {
    $dest = Join-Path $tmp ($f -replace '/', '\')
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null
    Invoke-WebRequest -Uri ($base + $f) -OutFile $dest -UseBasicParsing
  }
} catch {
  Say ('下载失败：' + $_.Exception.Message)
  Say '请检查网络后重跑本脚本（已完成的步骤会自动跳过）。'
  exit 1
}
Copy-Item (Join-Path $tmp 'templates') -Destination $libDir -Recurse -Force
Copy-Item (Join-Path $tmp 'scripts')   -Destination $libDir -Recurse -Force
Remove-Item $tmp -Recurse -Force
Ok '模板与脚本已就位（重复运行会自动覆盖更新，不影响你已填写的档案）'

# ---------- 4/7 生成全局记忆 AGENTS.md ----------
Say '[步骤] 4/7 全局记忆文件'
$agentsPath = Join-Path $libDir 'AGENTS.md'
if (Test-Path $agentsPath) {
  Ok 'AGENTS.md 已存在，跳过生成（不覆盖你的内容）。'
} else {
  if ($env:MB_USER_ID) { $id = $env:MB_USER_ID; Tip ('MB_USER_ID 已指定，跳过询问：' + $id) }
  else { $id = Read-Host '你的身份代号是？（会写进 AGENTS.md，例如 alice / 老张）' }
  if (-not $id) { $id = '我' }
  $tpl = Join-Path $libDir 'templates\AGENTS.template.md'
  if (-not (Test-Path $tpl)) { Warn '模板缺失，跳过本步。'; }
  else {
    $txt = Get-Content $tpl -Raw -Encoding UTF8
    $txt = $txt.Replace('<你的名字/代号>', $id)
    $txt = $txt.Replace('<品牌>', '（待填）')
    $txt = $txt.Replace('<填写总库路径>', $libDir)
    [System.IO.File]::WriteAllText($agentsPath, $txt, (New-Object System.Text.UTF8Encoding($false)))
    Ok 'AGENTS.md 已生成（身份代号已填，其余占位符请稍后补齐）'
  }
}

# ---------- 5/7 当前项目建档（可选） ----------
Say '[步骤] 5/7 当前项目建档（可选）'
$here = (Get-Location).Path
$projName = Split-Path $here -Leaf
$libRoot = (Get-Item $libDir).FullName
$insideLib = $here.StartsWith($libRoot, [System.StringComparison]::OrdinalIgnoreCase)
$doProj = $false
$askProj = $true
if ($env:MB_PROJECT_YES -eq '1') { $doProj = $true;  $askProj = $false; Tip 'MB_PROJECT_YES=1，跳过询问直接建档。' }
elseif ($env:MB_PROJECT_YES -eq '0') { $doProj = $false; $askProj = $false; Tip 'MB_PROJECT_YES=0，跳过建档。' }
if ($askProj -and $insideLib) { $askProj = $false; Tip '当前目录在记忆库内，跳过建档。' }
if ($askProj) {
  $ans = Read-Host ('把当前目录（' + $projName + '）建为第一个项目档案吗？[Y/n]')
  $doProj = -not ($ans -match '^[nN]')
}
if ($doProj) {
  $projDir = Join-Path $libDir 'projects'
  if (-not (Test-Path $projDir)) { New-Item -ItemType Directory -Force $projDir | Out-Null }
  $projFile = Join-Path $projDir ($projName + '.md')
  if (Test-Path $projFile) {
    Ok ('档案已存在，跳过：' + $projFile)
  } else {
    $ptpl = Join-Path $libDir 'templates\project.template.md'
    $ptxt = Get-Content $ptpl -Raw -Encoding UTF8
    $ptxt = $ptxt.Replace('<项目名>', $projName)
    [System.IO.File]::WriteAllText($projFile, $ptxt, (New-Object System.Text.UTF8Encoding($false)))
    Ok ('档案已生成：' + $projFile)
  }
  # merge into sync-map.json (existing keys are preserved)
  $mapPath = Join-Path $libDir 'sync-map.json'
  $map = [PSCustomObject]@{}
  if (Test-Path $mapPath) { $map = Get-Content $mapPath -Raw -Encoding UTF8 | ConvertFrom-Json }
  $key = $projName + '.md'
  $map | Add-Member -NotePropertyName $key -NotePropertyValue $here -Force
  [System.IO.File]::WriteAllText($mapPath, ($map | ConvertTo-Json -Depth 5), (New-Object System.Text.UTF8Encoding($false)))
  Ok ('sync-map.json 已更新（' + $key + ' -> ' + $here + '）')
} else {
  Tip '未建档。之后想建档：复制 templates\project.template.md 为 projects\<项目>.md，在 sync-map.json 加一行映射即可。'
}

# ---------- 6/7 git 版本控制（可选） ----------
Say '[步骤] 6/7 git 版本控制（可选）'
if (Get-Command git -ErrorAction SilentlyContinue) {
  if (-not (Test-Path (Join-Path $libDir '.git'))) {
    git -C $libDir init -q
    Ok 'git 仓库已初始化（记忆库即备份）'
  } else { Ok '已是 git 仓库，跳过。' }
} else {
  Warn '未检测到 git：跳过初始化。装上 git 后在该目录执行 git init 即可获得版本备份。'
}

# ---------- 7/7 首次同步 ----------
Say '[步骤] 7/7 首次同步'
$mapPath = Join-Path $libDir 'sync-map.json'
$sync = Join-Path $libDir 'scripts\sync-project-agents.ps1'
if (Test-Path $mapPath) {
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $sync -MapFile $mapPath
  # sync script is error-tolerant per entry; verify by artifacts instead of exit code
  $map2 = Get-Content $mapPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $allOk = $true
  foreach ($p in $map2.psobject.Properties) {
    $d = $p.Value
    if (-not [System.IO.Path]::IsPathRooted($d)) { $d = Join-Path (Split-Path $mapPath) $d }
    if (-not (Test-Path (Join-Path $d 'AGENTS.md'))) { $allOk = $false }
  }
  if ($allOk) { Ok '首次同步完成（项目根已生成 AGENTS.md 副本与 CLAUDE.md 桥接）' }
  else { Warn '部分目标未同步成功：请检查上方红字输出与 sync-map.json 里的路径。' }
} else {
  Tip '尚无 sync-map.json（未建档），跳过同步。以后运行：'
  Tip ('  powershell -ExecutionPolicy Bypass -File "' + $sync + '" -MapFile "' + $mapPath + '"')
}

Say '================================================================'
Say '  部署完成。'
Say '================================================================'
Say '  下一步：'
Say ('   1. 编辑 ' + $agentsPath + '：补齐技术偏好 / 协作原则 / 禁止事项')
Say '   2. Claude Code 用户如需全局记忆，在 %USERPROFILE%\.claude\CLAUDE.md 加一行：'
Say ('      @' + ($libDir -replace '\\', '/') + '/AGENTS.md')
Say '   3. 验证：在 coding agent 里新开一个会话，问"当前项目的定位是什么？"'
Say '   4. 更多用法（dsh / Cursor / 交接单 / spec 流程）见仓库 README：https://gitee.com/yellowgu/memoryboost'

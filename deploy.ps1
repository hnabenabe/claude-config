<#
.SYNOPSIS
    claude-config デプロイスクリプト
    共通ルール + 端末固有設定を結合して ~/.claude/CLAUDE.md に配置します

.EXAMPLE
    .\deploy.ps1 -Machine laptop
    .\deploy.ps1 -Machine office
    .\deploy.ps1 -Machine home
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("laptop", "office", "home")]
    [string]$Machine
)

$ErrorActionPreference = "Stop"

# パス設定
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } elseif ($MyInvocation.MyCommand.Path) { Split-Path -Parent $MyInvocation.MyCommand.Path } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$CommandsDir = Join-Path $ClaudeDir "commands"
$TargetMd = Join-Path $ClaudeDir "CLAUDE.md"

# 元ファイル
$CommonMd = Join-Path $ScriptDir "claude-md\common.md"
$MachineMd = Join-Path $ScriptDir "claude-md\$Machine.md"
$CommandsSource = Join-Path $ScriptDir "commands"

# -------------------------------------------------------
# 1. ~/.claude ディレクトリ作成
# -------------------------------------------------------
if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null
    Write-Host "[OK] Created $ClaudeDir" -ForegroundColor Green
}

# -------------------------------------------------------
# 2. CLAUDE.md のバックアップ
# -------------------------------------------------------
if (Test-Path $TargetMd) {
    $BackupPath = "$TargetMd.bak.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $TargetMd $BackupPath
    Write-Host "[OK] Backup: $BackupPath" -ForegroundColor Yellow
}

# -------------------------------------------------------
# 3. common.md + machine.md を結合
# -------------------------------------------------------
$Content = @()
$Content += Get-Content $CommonMd -Encoding UTF8
$Content += ""
$Content += "# ============================================"
$Content += "# Machine-specific settings ($Machine)"
$Content += "# ============================================"
$Content += ""
$Content += Get-Content $MachineMd -Encoding UTF8

$Content | Set-Content $TargetMd -Encoding UTF8
Write-Host "[OK] Deployed CLAUDE.md for [$Machine]" -ForegroundColor Green

# -------------------------------------------------------
# 4. commands/ をコピー
# -------------------------------------------------------
if (Test-Path $CommandsSource) {
    if (-not (Test-Path $CommandsDir)) {
        New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null
    }

    $Files = Get-ChildItem $CommandsSource -Filter "*.md"
    foreach ($File in $Files) {
        Copy-Item $File.FullName (Join-Path $CommandsDir $File.Name) -Force
        Write-Host "[OK] Command: $($File.Name)" -ForegroundColor Cyan
    }
}

# -------------------------------------------------------
# 5. 結果表示
# -------------------------------------------------------
Write-Host ""
Write-Host "=== Deploy complete ===" -ForegroundColor Green
Write-Host "  Target:  $TargetMd"
Write-Host "  Machine: $Machine"
Write-Host "  Commands: $(if (Test-Path $CommandsDir) { (Get-ChildItem $CommandsDir -Filter '*.md').Count } else { 0 }) files"
Write-Host ""
Write-Host "Contents:" -ForegroundColor Gray
Get-Content $TargetMd | Select-Object -First 5
Write-Host "  ..." -ForegroundColor DarkGray

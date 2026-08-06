<#
.SYNOPSIS
收集 Reasonix 生态站证据清单，输出 .reasonix/evidence/evidence-manifest.json。

.DESCRIPTION
扫描以下证据来源并生成统一清单（JSON）：
  - .reasonix/evidence/           证据文件
  - .reasonix/state/checkpoints/  任务检查点
  - .reasonix/state/handoffs/     交接包
  - .reasonix/reports/            验证与阶段报告

根路径由脚本所在目录推导（$PSScriptRoot 的上级即 .reasonix），
不硬编码任何旧绝对路径；支持 -ReasonixRoot 显式覆盖。

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\collect-evidence.ps1

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\collect-evidence.ps1 -DryRun
#>
param(
    [string]$ReasonixRoot = "",
    [switch]$DryRun = $false
)

$nl = [Environment]::NewLine

function Write-Status {
    param([string]$Stage, [string]$Detail)
    Write-Output "[STATUS] ${Stage} : ${Detail}"
}

# ---- 根路径推导：脚本位于 .reasonix\scripts\，上级即 .reasonix ----
if (-not $ReasonixRoot) {
    $ReasonixRoot = Split-Path $PSScriptRoot -Parent
}
if (-not (Test-Path -LiteralPath $ReasonixRoot)) {
    Write-Error "Reasonix root not found: $ReasonixRoot"
    exit 1
}

if ($DryRun) {
    Write-Status "DRYRUN" "Would collect evidence manifest under: $ReasonixRoot"
}

Write-Status "START" "Collect evidence v1.0 (Reasonix)"

# ---- 证据来源目录 ----
$scanDirs = @(
    @{ key = "evidence";    rel = "evidence" },
    @{ key = "checkpoints"; rel = "state\checkpoints" },
    @{ key = "handoffs";    rel = "state\handoffs" },
    @{ key = "reports";     rel = "reports" }
)

$evidenceFiles = @()
$totalBytes = 0
$missingDirs = @()

foreach ($entry in $scanDirs) {
    $dirPath = Join-Path $ReasonixRoot $entry.rel
    if (Test-Path -LiteralPath $dirPath) {
        $files = @(Get-ChildItem -LiteralPath $dirPath -Recurse -File -ErrorAction SilentlyContinue)
        foreach ($f in $files) {
            # 记录相对 .reasonix 的路径，保持清单可移植、不含驱动器绝对路径
            $rel = $f.FullName
            if ($rel.StartsWith($ReasonixRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
                $rel = $rel.Substring($ReasonixRoot.Length).TrimStart('\', '/')
            }
            $evidenceFiles += $rel
            $totalBytes += $f.Length
        }
        Write-Status "FOUND" "$($entry.key): $($files.Count) files"
    } else {
        $missingDirs += $entry.rel
        Write-Status "MISSING" "dir: $($entry.rel)"
    }
}

# ---- 清单 ----
$manifest = @{
    generated_at     = (Get-Date -Format "o")
    version          = "1.0.0"
    reasonix_root    = $ReasonixRoot
    evidence_files   = @($evidenceFiles)
    total_files      = $evidenceFiles.Count
    total_size_bytes = $totalBytes
    missing_dirs     = @($missingDirs)
    dry_run          = $DryRun.IsPresent
}

# ---- 输出 ----
if (-not $DryRun) {
    $outputDir = Join-Path $ReasonixRoot "evidence"
    if (-not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    $outputPath = Join-Path $outputDir "evidence-manifest.json"
    $manifest | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $outputPath -Encoding UTF8
    Write-Status "OUTPUT" "Saved to $outputPath"
}

Write-Status "COMPLETE" "Evidence collected: $($evidenceFiles.Count) files, $totalBytes bytes, $($missingDirs.Count) missing dirs"

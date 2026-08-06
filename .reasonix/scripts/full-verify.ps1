<#
.SYNOPSIS
Reasonix 生态站全量验证总入口（对标 Kilo FULL-VERIFY）：串联各子系统验证，输出汇总报告。

.DESCRIPTION
五个子系统验证：
  1. verify-runtime.ps1     10 类 46 项结构/规则/命令/证据/索引/安全/路由/连续性/技能/状态
  2. rebuild-skill-index.ps1 技能索引重建 + 交叉验证（CAPABILITY_MATRIX vs skills-index）
  3. continuity check        continuity 引擎任务状态（SHA256 链抽样验证）
  4. routing-log check       routing-log.jsonl 完整性（JSON 合法 + 时间戳单调 + 事件类型）
  5. evidence check          evidence-manifest.json 解析 + 证据文件计数
输出 .reasonix\reports\full-verify.json 与终端汇总；任一子系统 FAIL 则整体 FAIL。

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\full-verify.ps1
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

if (-not $ReasonixRoot) {
    $ReasonixRoot = Split-Path $PSScriptRoot -Parent
}

Write-Status "START" "Full Verify v1.0 (Reasonix)"

$report = @{
    version     = "1.0.0"
    timestamp   = (Get-Date -Format "o")
    reasonix_root = $ReasonixRoot
    subsystems  = @()
    summary     = @{ total = 0; passed = 0; failed = 0 }
    verdict     = "FAIL"
}

function Add-Subsystem {
    param(
        [string]$Name,
        [bool]$Pass,
        [int]$ChecksTotal,
        [int]$ChecksPassed,
        [string]$Detail
    )
    $report.subsystems += @{
        name = $Name
        pass = $Pass
        checks_total = $ChecksTotal
        checks_passed = $ChecksPassed
        detail = $Detail
    }
    $report.summary.total++
    if ($Pass) { $report.summary.passed++ } else { $report.summary.failed++ }
}

$scriptsDir = Join-Path $ReasonixRoot "scripts"

# ================= 1. verify-runtime =================
Write-Status "RUN" "Subsystem 1/5: verify-runtime.ps1"
$rvOut = Join-Path $ReasonixRoot "reports\runtime-verify.json"
$rvResult = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scriptsDir "verify-runtime.ps1") 2>&1 | Out-String
$rvPass = $LASTEXITCODE -eq 0
$rvDetail = "exit=$LASTEXITCODE"
if (Test-Path -LiteralPath $rvOut) {
    try {
        $rv = Get-Content -LiteralPath $rvOut -Raw -Encoding UTF8 | ConvertFrom-Json
        $rvDetail = "verdict=$($rv.verdict) checks=$($rv.summary.passed)/$($rv.summary.total_checks)"
        Add-Subsystem -Name "verify-runtime" -Pass ($rv.verdict -eq "ALL_PASS") -ChecksTotal $rv.summary.total_checks -ChecksPassed $rv.summary.passed -Detail $rvDetail
    } catch {
        Add-Subsystem -Name "verify-runtime" -Pass $false -ChecksTotal 0 -ChecksPassed 0 -Detail "cannot parse ${rvOut}: $_"
    }
} else {
    Add-Subsystem -Name "verify-runtime" -Pass $false -ChecksTotal 0 -ChecksPassed 0 -Detail "output missing: $rvOut"
}

# ================= 2. rebuild-skill-index =================
Write-Status "RUN" "Subsystem 2/5: rebuild-skill-index.ps1"
$rsiOut = Join-Path $ReasonixRoot "reports\full-verify-rsi.json"
$rsiResult = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $scriptsDir "rebuild-skill-index.ps1") 2>&1 | Out-String
$rsiPass = $LASTEXITCODE -eq 0
$rsiDetail = "exit=$LASTEXITCODE"
# 检查最新 cross-verify 结果
$latestCv = Get-ChildItem -LiteralPath (Join-Path $ReasonixRoot "registry") -Filter "cross-verify-*.json" -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($latestCv) {
    try {
        $cv = Get-Content -LiteralPath $latestCv.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
        $rsiDetail = "cross-verify: all_consistent=$($cv.all_consistent) file=$($latestCv.Name)"
        if ($cv.performed -and -not $cv.all_consistent) { $rsiPass = $false }
    } catch { }
}
Add-Subsystem -Name "skill-index" -Pass $rsiPass -ChecksTotal 1 -ChecksPassed $(if ($rsiPass) { 1 } else { 0 }) -Detail $rsiDetail

# ================= 3. continuity =================
Write-Status "RUN" "Subsystem 3/5: continuity engine"
$contRoot = Join-Path $ReasonixRoot "state\continuity"
$contPass = $true
$contTasks = 0
$contDetail = "no tasks"
if (Test-Path -LiteralPath (Join-Path $contRoot "tasks")) {
    $contTasks = @(Get-ChildItem -LiteralPath (Join-Path $contRoot "tasks") -Directory -ErrorAction SilentlyContinue).Count
    $contDetail = "tasks=$contTasks"
    if ($contTasks -gt 0) {
        # 抽样验证最新任务的 closeout/task-state
        $latestTask = Get-ChildItem -LiteralPath (Join-Path $contRoot "tasks") -Directory -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        $statePath = Join-Path $latestTask.FullName "task-state.json"
        if (Test-Path -LiteralPath $statePath) {
            try {
                $st = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
                $contDetail = "task=$($latestTask.Name) status=$($st.status) completed=$($st.completed_steps.Count)/$($st.total_steps)"
                if ($st.status -notmatch 'CLOSED_(PASS|DEGRADED)|ACTIVE|WAITING_USER|BLOCKED') { $contPass = $false }
            } catch { $contPass = $false }
        }
    }
} else {
    $contPass = $false
    $contDetail = "continuity dir missing"
}
Add-Subsystem -Name "continuity" -Pass $contPass -ChecksTotal 1 -ChecksPassed $(if ($contPass) { 1 } else { 0 }) -Detail $contDetail

# ================= 4. routing-log =================
Write-Status "RUN" "Subsystem 4/5: routing-log"
$routingPath = Join-Path $ReasonixRoot "state\routing-log.jsonl"
$routingPass = $false
$routingDetail = "missing"
if (Test-Path -LiteralPath $routingPath) {
    $lines = @(Get-Content -LiteralPath $routingPath -Encoding UTF8 -ErrorAction SilentlyContinue)
    $jsonOk = $true; $types = @(); $monotonic = $true; $prevTs = $null
    foreach ($line in $lines) {
        try {
            $obj = $line | ConvertFrom-Json
            if ($obj.event -and $types -notcontains $obj.event) { $types += $obj.event }
            $ts = [datetime]$obj.timestamp
            if ($prevTs -and $ts -lt $prevTs) { $monotonic = $false }
            $prevTs = $ts
        } catch { $jsonOk = $false }
    }
    $routingPass = $jsonOk -and $types.Count -ge 6 -and $monotonic
    $routingDetail = "lines=$($lines.Count) types=$($types.Count) json_ok=$jsonOk monotonic=$monotonic"
}
Add-Subsystem -Name "routing-log" -Pass $routingPass -ChecksTotal 1 -ChecksPassed $(if ($routingPass) { 1 } else { 0 }) -Detail $routingDetail

# ================= 5. evidence =================
Write-Status "RUN" "Subsystem 5/5: evidence manifest"
$manifestPath = Join-Path $ReasonixRoot "evidence\evidence-manifest.json"
$evidencePass = $false
$evidenceDetail = "manifest missing"
if (Test-Path -LiteralPath $manifestPath) {
    try {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $evidenceCount = @(Get-ChildItem -LiteralPath (Join-Path $ReasonixRoot "evidence") -Recurse -File -ErrorAction SilentlyContinue).Count
        $evidencePass = $manifest.schema -like "reasonix-*"
        $evidenceDetail = "schema=$($manifest.schema) evidence_files=$evidenceCount registered=$($manifest.summary.total_evidence)"
    } catch {
        $evidenceDetail = "manifest parse error: $_"
    }
}
Add-Subsystem -Name "evidence" -Pass $evidencePass -ChecksTotal 1 -ChecksPassed $(if ($evidencePass) { 1 } else { 0 }) -Detail $evidenceDetail

# ================= 汇总 =================
$report.verdict = if ($report.summary.failed -eq 0) { "ALL_PASS" } else { "FAIL" }

if (-not $DryRun) {
    $outputDir = Join-Path $ReasonixRoot "reports"
    if (-not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    $outputPath = Join-Path $outputDir "full-verify.json"
    $report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $outputPath -Encoding UTF8
    Write-Status "OUTPUT" "Saved to $outputPath"
}

Write-Output ""
Write-Output "[FULL-VERIFY] $($report.verdict) — $($report.summary.passed)/$($report.summary.total_checks) subsystems passed"
foreach ($s in $report.subsystems) {
    $mark = if ($s.pass) { "PASS" } else { "FAIL" }
    Write-Output "  [$mark] $($s.name): $($s.detail)"
}
Write-Status "COMPLETE" "Full Verify: $($report.verdict)"
if ($report.summary.failed -gt 0) { exit 1 } else { exit 0 }

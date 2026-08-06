<#
.SYNOPSIS
Reasonix 生态站运行时验证 V2.0：10 类 ~43 项检查，输出 .reasonix\reports\runtime-verify.json 与终端汇总。

.DESCRIPTION
十类验证（对标 Kilo 成熟站 FULL-VERIFY 标准）：
  1. structure   必填目录存在（15 项）
  2. rules       .reasonix\rules 6 规则文件存在（6 项）
  3. commands    checkpoint/resume/handoff 命令存在（3 项）
  4. evidence    证据清单+顶层证据+子目录（3 项）
  5. index       registry 4 文件存在且 JSON 可解析（4 项）
  6. security    禁止模式扫描+密钥扫描（2 项）
  7. routing     routing-log 存在+JSON合法+类型覆盖+闭环（4 项）
  8. continuity  continuity 引擎目录+核心库+脚本+任务（4 项）
  9. skills      11 技能 SKILL.md 齐全+frontmatter（3 项）
  10. state      checkpoints+handoffs 状态目录（2 项）
终端输出 ALL_PASS 或逐项列出 FAIL；存在 FAIL 时退出码为 1。

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\verify-runtime.ps1

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\verify-runtime.ps1 -ReasonixRoot "D:\some\workspace\.reasonix" -DryRun
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
    Write-Status "DRYRUN" "Would verify runtime under: $ReasonixRoot"
}

Write-Status "START" "Verify runtime v2.0 (Reasonix)"

$failedChecks = @()
$results = @{
    version        = "2.0.0"
    timestamp      = (Get-Date -Format "o")
    reasonix_root  = $ReasonixRoot
    dry_run        = $DryRun.IsPresent
    categories     = @{}
    summary        = @{ total_checks = 0; passed = 0; failed = 0; warnings = 0 }
    verdict        = "FAIL"
}

function Add-Check {
    param(
        [hashtable]$Category,
        [string]$Name,
        [bool]$Pass,
        [object]$Extra = $null
    )
    $check = @{ name = $Name; pass = $Pass }
    if ($null -ne $Extra) { $check["detail"] = $Extra }
    $Category.checks += $check
    if ($Pass) { $Category.passed++ } else { $Category.failed++ }
    return $Pass
}

function Register-Category {
    param([hashtable]$Category, [string]$Name)
    $results.categories[$Name] = $Category
    $results.summary.total_checks += $Category.checks.Count
    $results.summary.passed += $Category.passed
    $results.summary.failed += $Category.failed
    if ($Category.failed -gt 0) {
        foreach ($c in $Category.checks | Where-Object { -not $_.pass }) {
            $failedChecks += "${Name}: $($c.name)"
        }
    }
}

# ================= 1. Structure (15 dirs) =================
Write-Status "CHECK" "Category 1: Structure"
$structure = @{ checks = @(); passed = 0; failed = 0 }
$requiredDirs = @(
    "skills", "scripts", "evidence", "state", "state\checkpoints",
    "state\handoffs", "state\continuity", "reports", "registry", "rules",
    "commands", "evidence\maturity-validation", "evidence\video-frames",
    "skills\reasonix-continuity\lib", "skills\reasonix-continuity\scripts"
)
foreach ($dir in $requiredDirs) {
    $path = Join-Path $ReasonixRoot $dir
    $exists = Test-Path -LiteralPath $path
    [void](Add-Check -Category $structure -Name "dir:$dir" -Pass $exists)
    if (-not $exists) { Write-Status "MISSING" "dir: $dir" }
}
Register-Category -Category $structure -Name "structure"
Write-Status "PASS" "Structure: $($structure.passed)/$($structure.checks.Count)"

# ================= 2. Rules (6 files) =================
Write-Status "CHECK" "Category 2: Rules"
$rules = @{ checks = @(); passed = 0; failed = 0 }
$ruleFiles = @("core-rules.md", "coding-rules.md", "security-rules.md", "review-rules.md", "testing-rules.md", "long-task-rules.md")
$rulesDir = Join-Path $ReasonixRoot "rules"
foreach ($rf in $ruleFiles) {
    $path = Join-Path $rulesDir $rf
    $exists = Test-Path -LiteralPath $path
    [void](Add-Check -Category $rules -Name "rule:$rf" -Pass $exists)
}
Register-Category -Category $rules -Name "rules"
Write-Status "PASS" "Rules: $($rules.passed)/$($rules.checks.Count)"

# ================= 3. Commands (3) =================
Write-Status "CHECK" "Category 3: Commands"
$commands = @{ checks = @(); passed = 0; failed = 0 }
$commandsDir = Join-Path $ReasonixRoot "commands"
$cmdFiles = @("checkpoint.md", "resume.md", "handoff.md")
foreach ($cf in $cmdFiles) {
    $path = Join-Path $commandsDir $cf
    $exists = Test-Path -LiteralPath $path
    [void](Add-Check -Category $commands -Name "cmd:$cf" -Pass $exists)
}
Register-Category -Category $commands -Name "commands"
Write-Status "PASS" "Commands: $($commands.passed)/$($commands.checks.Count)"

# ================= 4. Evidence (3) =================
Write-Status "CHECK" "Category 4: Evidence"
$evidence = @{ checks = @(); passed = 0; failed = 0 }
$evidenceDir = Join-Path $ReasonixRoot "evidence"
$manifestPath = Join-Path $evidenceDir "evidence-manifest.json"
$manifestOk = Test-Path -LiteralPath $manifestPath
if ($manifestOk) {
    try {
        $null = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        $manifestOk = $true
    } catch { $manifestOk = $false }
}
[void](Add-Check -Category $evidence -Name "manifest_json_valid" -Pass $manifestOk)
$topCount = 0
if (Test-Path -LiteralPath $evidenceDir) {
    $topCount = @(Get-ChildItem -LiteralPath $evidenceDir -File -ErrorAction SilentlyContinue).Count
}
[void](Add-Check -Category $evidence -Name "evidence_top_level" -Pass ($topCount -gt 0) -Extra @{ count = $topCount })
$matCount = 0
$matDir = Join-Path $evidenceDir "maturity-validation"
if (Test-Path -LiteralPath $matDir) {
    $matCount = @(Get-ChildItem -LiteralPath $matDir -Recurse -File -ErrorAction SilentlyContinue).Count
}
[void](Add-Check -Category $evidence -Name "maturity_validation" -Pass ($matCount -gt 0) -Extra @{ count = $matCount })
Register-Category -Category $evidence -Name "evidence"
Write-Status "PASS" "Evidence: $($evidence.passed)/$($evidence.checks.Count)"

# ================= 5. Index (4) =================
Write-Status "CHECK" "Category 5: Index"
$index = @{ checks = @(); passed = 0; failed = 0 }
$registryDir = Join-Path $ReasonixRoot "registry"
$indexFiles = @("SKILLS_INDEX.md", "skills-index.json", "CAPABILITY_MATRIX.json", "tool-registry.json")
foreach ($if in $indexFiles) {
    $path = Join-Path $registryDir $if
    $ok = Test-Path -LiteralPath $path
    if ($ok -and $if -like "*.json") {
        try {
            $null = Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json
        } catch { $ok = $false }
    }
    [void](Add-Check -Category $index -Name "registry:$if" -Pass $ok)
}
Register-Category -Category $index -Name "index"
Write-Status "PASS" "Index: $($index.passed)/$($index.checks.Count)"

# ================= 6. Security (2) =================
Write-Status "CHECK" "Category 6: Security"
$security = @{ checks = @(); passed = 0; failed = 0 }
$bannedPatterns = @(
    'sk-[A-Za-z0-9]{20,}',
    "OPENROUTER_API_KEY\s*=\s*['\`"]" + 'sk-or-',  # 硬编码赋值才禁止，环境变量读取合法
    ('Her' + 'mes'),
    ('C:\\Users\\A' + '\\.codex'),
    ('kilo\.' + 'jsonc'),
    ('\.' + 'kilo')
)
$securityHits = @()
if (-not $DryRun) {
    $scanRoot = Join-Path $ReasonixRoot "scripts"
    if (Test-Path -LiteralPath $scanRoot) {
        $scanFiles = @(Get-ChildItem -LiteralPath $scanRoot -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne 'verify-runtime.ps1' -and $_.FullName -notmatch '\\tmp\\' })
        foreach ($f in $scanFiles) {
            try {
                $content = Get-Content -LiteralPath $f.FullName -Raw -ErrorAction SilentlyContinue
                if (-not $content) { continue }
                foreach ($p in $bannedPatterns) {
                    if ($content -match $p) {
                        $securityHits += @{ file = $f.FullName; pattern = $p }
                        break
                    }
                }
            } catch { }
        }
    }
}
$secPass = if ($DryRun) { $true } else { $securityHits.Count -eq 0 }
[void](Add-Check -Category $security -Name "banned_pattern_scan" -Pass $secPass -Extra @{ hits = $securityHits.Count })
# 密钥模式扫描（README/scripts）
$keyPatterns = @('AKIA[0-9A-Z]{16}', 'BEGIN PRIVATE KEY', 'ghp_[A-Za-z0-9]{30,}', ('sk-or-v1-' + '[A-Za-z0-9]{20,}'))
$keyHits = @()
if (-not $DryRun) {
    $scanDirs = @((Join-Path $ReasonixRoot "scripts"), (Join-Path $ReasonixRoot "skills"), (Join-Path $ReasonixRoot "registry"))
    foreach ($sd in $scanDirs) {
        if (-not (Test-Path -LiteralPath $sd)) { continue }
        $files = @(Get-ChildItem -LiteralPath $sd -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -ne 'verify-runtime.ps1' })
        foreach ($f in $files) {
            try {
                $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if (-not $content) { continue }
                foreach ($kp in $keyPatterns) {
                    if ($content -match $kp) { $keyHits += $f.FullName; break }
                }
            } catch { }
        }
    }
}
$keyPass = if ($DryRun) { $true } else { $keyHits.Count -eq 0 }
[void](Add-Check -Category $security -Name "secret_key_scan" -Pass $keyPass -Extra @{ hits = $keyHits.Count })
Register-Category -Category $security -Name "security"
Write-Status "PASS" "Security: $($security.passed)/$($security.checks.Count)"

# ================= 7. Routing (4) =================
Write-Status "CHECK" "Category 7: Routing"
$routing = @{ checks = @(); passed = 0; failed = 0 }
$routingPath = Join-Path $ReasonixRoot "state\routing-log.jsonl"
$routingExists = Test-Path -LiteralPath $routingPath
[void](Add-Check -Category $routing -Name "routing_log_exists" -Pass $routingExists)
$jsonOk = $false; $eventTypes = @(); $monotonic = $true; $typeCount = 0
if ($routingExists) {
    $lines = @(Get-Content -LiteralPath $routingPath -Encoding UTF8 -ErrorAction SilentlyContinue)
    $jsonOk = $true
    $prevTs = $null
    foreach ($line in $lines) {
        try {
            $obj = $line | ConvertFrom-Json
            if ($obj.event -and $eventTypes -notcontains $obj.event) { $eventTypes += $obj.event }
            $ts = [datetime]$obj.timestamp
            if ($prevTs -and $ts -lt $prevTs) { $monotonic = $false }
            $prevTs = $ts
        } catch { $jsonOk = $false }
    }
    $typeCount = $eventTypes.Count
}
[void](Add-Check -Category $routing -Name "routing_json_valid" -Pass $jsonOk)
[void](Add-Check -Category $routing -Name "routing_type_coverage" -Pass ($typeCount -ge 6) -Extra @{ types = $typeCount })
[void](Add-Check -Category $routing -Name "routing_timestamp_monotonic" -Pass $monotonic)
Register-Category -Category $routing -Name "routing"
Write-Status "PASS" "Routing: $($routing.passed)/$($routing.checks.Count), $typeCount event types"

# ================= 8. Continuity (4) =================
Write-Status "CHECK" "Category 8: Continuity"
$continuity = @{ checks = @(); passed = 0; failed = 0 }
$contRoot = Join-Path $ReasonixRoot "state\continuity"
[void](Add-Check -Category $continuity -Name "continuity_dir" -Pass (Test-Path -LiteralPath $contRoot))
$contLib = Join-Path $ReasonixRoot "skills\reasonix-continuity\lib\continuity.py"
[void](Add-Check -Category $continuity -Name "continuity_lib" -Pass (Test-Path -LiteralPath $contLib))
$contScripts = @("new-task.py", "save-checkpoint.py", "write-handoff.py", "resume-task.py", "close-task.py")
$scriptDir = Join-Path $ReasonixRoot "skills\reasonix-continuity\scripts"
$scriptsOk = $true
foreach ($cs in $contScripts) {
    if (-not (Test-Path -LiteralPath (Join-Path $scriptDir $cs))) { $scriptsOk = $false }
}
[void](Add-Check -Category $continuity -Name "continuity_scripts" -Pass $scriptsOk -Extra @{ scripts = $contScripts.Count })
$taskCount = 0
if (Test-Path -LiteralPath (Join-Path $contRoot "tasks")) {
    $taskCount = @(Get-ChildItem -LiteralPath (Join-Path $contRoot "tasks") -Directory -ErrorAction SilentlyContinue).Count
}
[void](Add-Check -Category $continuity -Name "continuity_tasks" -Pass ($taskCount -gt 0) -Extra @{ tasks = $taskCount })
Register-Category -Category $continuity -Name "continuity"
Write-Status "PASS" "Continuity: $($continuity.passed)/$($continuity.checks.Count)"

# ================= 9. Skills (3) =================
Write-Status "CHECK" "Category 9: Skills"
$skills = @{ checks = @(); passed = 0; failed = 0 }
$skillNames = @(
    "reasonix-continuity", "reasonix-ecc-orchestration", "reasonix-evidence-repair",
    "reasonix-executor-repair", "reasonix-gate-controller", "reasonix-loop",
    "reasonix-mature-core", "reasonix-research", "reasonix-review-audit",
    "reasonix-test-verify", "reasonix-vision-review"
)
$skillDir = Join-Path $ReasonixRoot "skills"
$found = 0
foreach ($sn in $skillNames) {
    if (Test-Path -LiteralPath (Join-Path $skillDir (Join-Path $sn "SKILL.md"))) { $found++ }
}
[void](Add-Check -Category $skills -Name "skill_skilmd_present" -Pass ($found -eq $skillNames.Count) -Extra @{ found = $found; expected = $skillNames.Count })
$fmOk = $true; $checked = 0
foreach ($sn in $skillNames) {
    $mdPath = Join-Path $skillDir (Join-Path $sn "SKILL.md")
    if (Test-Path -LiteralPath $mdPath) {
        $checked++
        $content = Get-Content -LiteralPath $mdPath -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($content -notmatch '(?ms)^---\s*\r?\nname:\s*.+?\r?\ndescription:\s*.+?\r?\n(?:runAs:\s*\S+\r?\n)?---') {
            $fmOk = $false
        }
    }
}
[void](Add-Check -Category $skills -Name "skill_frontmatter" -Pass ($fmOk -and $checked -gt 0) -Extra @{ checked = $checked })
$absorbCount = @("reasonix-continuity", "reasonix-evidence-repair", "reasonix-loop", "reasonix-ecc-orchestration" |
    Where-Object { Test-Path -LiteralPath (Join-Path $skillDir (Join-Path $_ "SKILL.md")) }).Count
[void](Add-Check -Category $skills -Name "absorbed_skills" -Pass ($absorbCount -eq 4) -Extra @{ absorbed = $absorbCount })
Register-Category -Category $skills -Name "skills"
Write-Status "PASS" "Skills: $($skills.passed)/$($skills.checks.Count), $found/$($skillNames.Count) SKILL.md found"

# ================= 10. State (2) =================
Write-Status "CHECK" "Category 10: State"
$state = @{ checks = @(); passed = 0; failed = 0 }
$ckptDir = Join-Path $ReasonixRoot "state\checkpoints"
$ckptCount = 0
if (Test-Path -LiteralPath $ckptDir) {
    $ckptCount = @(Get-ChildItem -LiteralPath $ckptDir -Filter "CHECKPOINT-*.json" -File -ErrorAction SilentlyContinue).Count
}
[void](Add-Check -Category $state -Name "checkpoints_present" -Pass ($ckptCount -gt 0) -Extra @{ count = $ckptCount })
$hoDir = Join-Path $ReasonixRoot "state\handoffs"
$hoCount = 0
if (Test-Path -LiteralPath $hoDir) {
    $hoCount = @(Get-ChildItem -LiteralPath $hoDir -Filter "HANDOFF-*.json" -File -ErrorAction SilentlyContinue).Count
}
[void](Add-Check -Category $state -Name "handoffs_present" -Pass ($hoCount -gt 0) -Extra @{ count = $hoCount })
Register-Category -Category $state -Name "state"
Write-Status "PASS" "State: $($state.passed)/$($state.checks.Count)"

# ================= 汇总 =================
$results.summary.warnings = 0
$verdict = if ($results.summary.failed -eq 0) { "ALL_PASS" } else { "FAIL" }
$results.verdict = $verdict
$results.failed_checks = @($failedChecks)

if (-not $DryRun) {
    $outputDir = Join-Path $ReasonixRoot "reports"
    if (-not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    $outputPath = Join-Path $outputDir "runtime-verify.json"
    $results | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $outputPath -Encoding UTF8
    Write-Status "OUTPUT" "Saved to $outputPath"
}

Write-Output ""
Write-Output "[VERDICT] $verdict — $($results.summary.passed)/$($results.summary.total_checks) checks passed"
if ($failedChecks.Count -gt 0) {
    Write-Output "[FAIL] Failed checks:"
    foreach ($fc in $failedChecks) {
        Write-Output "  - $fc"
    }
}

Write-Status "COMPLETE" "Verify runtime: $verdict"
if ($results.summary.failed -gt 0) { exit 1 } else { exit 0 }

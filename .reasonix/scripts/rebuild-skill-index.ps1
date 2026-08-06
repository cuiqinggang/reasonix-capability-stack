<#
.SYNOPSIS
重建 Reasonix 技能索引：扫描 .reasonix\skills\*\SKILL.md，输出 .reasonix\registry\SKILLS_INDEX.md（Markdown 表）与 skills-index.json。

.DESCRIPTION
遍历 .reasonix\skills 下每个技能目录，解析其 SKILL.md 的 frontmatter（name / description / runAs），
生成 Markdown 索引表（含相对路径）。描述文本做换行与竖线清洗，防止破坏表格。

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\rebuild-skill-index.ps1

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\rebuild-skill-index.ps1 -ReasonixRoot "D:\some\workspace\.reasonix" -DryRun
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
$skillsRoot = Join-Path $ReasonixRoot "skills"
if (-not (Test-Path -LiteralPath $skillsRoot)) {
    Write-Error "Skills root not found: $skillsRoot"
    exit 1
}

if ($DryRun) {
    Write-Status "DRYRUN" "Would rebuild skill index under: $skillsRoot"
}

Write-Status "START" "Rebuild skill index v1.0 (Reasonix)"

# ---- frontmatter 解析 ----
function Get-Frontmatter {
    param([string]$FilePath)
    $content = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return @{ name = ""; description = ""; runAs = "" } }
    $fmMatch = [regex]::Match($content, '(?ms)^---\s*\r?\n(.*?)^---\s*\r?\n')
    if (-not $fmMatch.Success) { return @{ name = ""; description = ""; runAs = "" } }
    $fm = $fmMatch.Groups[1].Value
    $name = ""; $description = ""; $runAs = ""
    $m1 = [regex]::Match($fm, '(?m)^name:\s*(.+?)\s*$')
    if ($m1.Success) { $name = $m1.Groups[1].Value.Trim() }
    $m2 = [regex]::Match($fm, '(?m)^description:\s*(.+?)\s*$')
    if ($m2.Success) { $description = $m2.Groups[1].Value.Trim() }
    $m3 = [regex]::Match($fm, '(?m)^runAs:\s*(.+?)\s*$')
    if ($m3.Success) { $runAs = $m3.Groups[1].Value.Trim() }
    return @{ name = $name; description = $description; runAs = $runAs }
}

# ---- 清洗单元格文本 ----
function Format-Cell {
    param([string]$Text, [int]$MaxLen = 80)
    $t = $Text -replace '\s+', ' ' -replace '\|', '\|'
    if ($t.Length -gt $MaxLen) { $t = $t.Substring(0, $MaxLen) + "…" }
    return $t.Trim()
}

# ---- 扫描技能 ----
$skills = @()
$skillDirs = @(Get-ChildItem -LiteralPath $skillsRoot -Directory -ErrorAction SilentlyContinue)
foreach ($dir in $skillDirs) {
    $skillMd = Join-Path $dir.FullName "SKILL.md"
    $entry = @{
        name        = $dir.Name
        rel_dir     = "skills\$($dir.Name)"
        has_skill_md = $false
        description = ""
        runAs       = ""
        size_bytes  = 0
    }
    if (Test-Path -LiteralPath $skillMd) {
        $entry.has_skill_md = $true
        $entry.size_bytes = (Get-Item -LiteralPath $skillMd).Length
        $fm = Get-Frontmatter -FilePath $skillMd
        if ($fm.name) { $entry.name = $fm.name }
        $entry.description = $fm.description
        $entry.runAs = $fm.runAs
        Write-Status "FOUND" "SKILL.md: $($dir.Name) (runAs=$($fm.runAs))"
    } else {
        Write-Status "EMPTY" "No SKILL.md: $($dir.Name)"
    }
    $skills += $entry
}

$withSkillMd = @($skills | Where-Object { $_.has_skill_md }).Count

# ---- 输出 ----
$outputDir = Join-Path $ReasonixRoot "registry"
$mdPath = Join-Path $outputDir "SKILLS_INDEX.md"
$jsonPath = Join-Path $outputDir "skills-index.json"

if (-not $DryRun) {
    if (-not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    # 读取现有 curated 元数据（保留手工维护的 status_details / builtin_tools 等字段）
    $curated = @{}
    if (Test-Path -LiteralPath $jsonPath) {
        try {
            $existing = Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json
            if ($existing.schema) { $curated['schema'] = $existing.schema }
            if ($existing.maintainer) { $curated['maintainer'] = $existing.maintainer }
            if ($existing.note) { $curated['note'] = $existing.note }
            if ($existing.summary) {
                $curatedSummary = @{}
                $existing.summary.PSObject.Properties | ForEach-Object {
                    if ($_.Name -notin @('total_skill_dirs','with_skill_md','without_skill_md','skills_root','skill_total','ready')) {
                        $curatedSummary[$_.Name] = $_.Value
                    }
                }
                if ($curatedSummary.Count -gt 0) { $curated['summary_extra'] = $curatedSummary }
            }
            if ($existing.builtin_tools) { $curated['builtin_tools'] = @($existing.builtin_tools) }
        } catch { Write-Status "WARN" "Could not read existing skills-index.json for curation: $_" }
    }

    # JSON 副产物（合并自动生成的 skills + 保留的 curated 元数据）
    $index = [ordered]@{}
    if ($curated['schema']) { $index['schema'] = $curated['schema'] }
    $index['generated'] = (Get-Date -Format "o")
    if ($curated['maintainer']) { $index['maintainer'] = $curated['maintainer'] }
    if ($curated['note']) { $index['note'] = $curated['note'] }
    $index['summary'] = [ordered]@{
        skill_total = $skills.Count
        ready = $withSkillMd
    }
    if ($curated['summary_extra']) {
        $curated['summary_extra'].GetEnumerator() | ForEach-Object {
            $index['summary'][$_.Key] = $_.Value
        }
    }
    $index['skills'] = @($skills)
    if ($curated['builtin_tools']) { $index['builtin_tools'] = $curated['builtin_tools'] }
    $index | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
    Write-Status "OUTPUT" "JSON: $jsonPath"

    # Markdown 表
    $md = @()
    $md += "# Skills Index"
    $md += ""
    $md += "Generated: $($index.generated_at)"
    $md += "Version: $($index.version)"
    $md += ""
    $md += "## Summary"
    $md += ""
    $md += "- Total skill directories: $($skills.Count)"
    $md += "- With SKILL.md: $withSkillMd"
    $md += "- Without SKILL.md: $($skills.Count - $withSkillMd)"
    $md += ""
    $md += "## Indexed Skills"
    $md += ""
    $md += "| name | description | runAs | path |"
    $md += "|------|-------------|-------|------|"
    foreach ($s in $skills) {
        $runAsCell = if ($s.runAs) { (Format-Cell $s.runAs 20) } else { "inline" }
        $descCell = if ($s.has_skill_md) { (Format-Cell $s.description 80) } else { "NO SKILL.md" }
        $md += "| $($s.name) | $descCell | $runAsCell | $($s.rel_dir)\SKILL.md |"
    }
    $md += ""
    $md += "_Generated by rebuild-skill-index.ps1. Do not edit by hand._"

    $mdContent = $md -join $nl
    Set-Content -LiteralPath $mdPath -Value $mdContent -Encoding UTF8
    Write-Status "OUTPUT" "Markdown: $mdPath"
} else {
    Write-Status "DRYRUN" "Would write SKILLS_INDEX.md and skills-index.json under $outputDir"
}

# ---- 交叉验证：对比 CAPABILITY_MATRIX.json 与 skills-index.json 状态一致性 ----
Write-Status "CROSS-VERIFY" "Checking cross-index consistency..."

$matrixPath = Join-Path $outputDir "CAPABILITY_MATRIX.json"
$crossVerify = @{
    performed = $false
    matrix_found = $false
    checks = @()
    all_consistent = $false
}

if (Test-Path -LiteralPath $matrixPath) {
    $crossVerify.matrix_found = $true
    try {
        $matrix = Get-Content -LiteralPath $matrixPath -Raw | ConvertFrom-Json
        $skillIndex = if ($jsonPath -and (Test-Path -LiteralPath $jsonPath)) {
            Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json
        } else { $null }

        # Check 1: vision-review 图片状态一致性
        $matrixVisionStatus = $null
        foreach ($cap in $matrix.capabilities) {
            if ($cap.id -eq "CAP-10" -and $cap.sub_capabilities) {
                foreach ($sub in $cap.sub_capabilities) {
                    if ($sub.name -match "图片") { $matrixVisionStatus = $sub.status }
                }
            }
        }
        $indexVisionStatus = if ($skillIndex.summary.status_details.vision_review_image) {
            $skillIndex.summary.status_details.vision_review_image
        } else { "NOT_FOUND" }
        $visionConsistent = ($matrixVisionStatus -eq $indexVisionStatus)
        $crossVerify.checks += @{
            name = "vision_review_image_status"
            matrix = $matrixVisionStatus
            index = $indexVisionStatus
            consistent = $visionConsistent
        }
        Write-Status "CROSS-VERIFY" "Vision image: matrix=$matrixVisionStatus index=$indexVisionStatus consistent=$visionConsistent"

        # Check 2: checkpoint/resume 状态一致性
        $matrixCheckpointStatus = $null
        foreach ($cap in $matrix.capabilities) {
            if ($cap.id -eq "CAP-11") { $matrixCheckpointStatus = $cap.status }
        }
        $indexCheckpointStatus = if ($skillIndex.summary.status_details.checkpoint_handoff_resume) {
            $skillIndex.summary.status_details.checkpoint_handoff_resume
        } else { "NOT_FOUND" }
        $checkpointConsistent = ($matrixCheckpointStatus -eq $indexCheckpointStatus)
        $crossVerify.checks += @{
            name = "checkpoint_handoff_resume_status"
            matrix = $matrixCheckpointStatus
            index = $indexCheckpointStatus
            consistent = $checkpointConsistent
        }
        Write-Status "CROSS-VERIFY" "Checkpoint/resume: matrix=$matrixCheckpointStatus index=$indexCheckpointStatus consistent=$checkpointConsistent"

        # Check 3: 技能数量一致性
        $matrixSkillCount = if ($skillIndex.skills) { $skillIndex.skills.Count } else { 0 }
        $indexSkillCount = if ($skillIndex.summary.skill_total) { $skillIndex.summary.skill_total } else { 0 }
        $countConsistent = ($matrixSkillCount -eq $indexSkillCount)
        $crossVerify.checks += @{
            name = "skill_count"
            matrix_skills = $matrixSkillCount
            index_total = $indexSkillCount
            consistent = $countConsistent
        }

        $crossVerify.all_consistent = ($crossVerify.checks | Where-Object { -not $_.consistent }).Count -eq 0
        $crossVerify.performed = $true
    } catch {
        Write-Status "CROSS-VERIFY" "ERROR: $_"
        $crossVerify.checks += @{ name = "parse_error"; error = "$_" }
    }
} else {
    Write-Status "CROSS-VERIFY" "SKIPPED: CAPABILITY_MATRIX.json not found at $matrixPath"
}

if ($crossVerify.performed) {
    $cvPath = Join-Path $outputDir "cross-verify-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $crossVerify | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $cvPath -Encoding UTF8
    Write-Status "CROSS-VERIFY" "$(if ($crossVerify.all_consistent) { 'ALL_CONSISTENT' } else { 'MISMATCH_DETECTED' }) → $cvPath"
}

Write-Status "COMPLETE" "Skill index rebuilt: $withSkillMd of $($skills.Count) skills have SKILL.md"

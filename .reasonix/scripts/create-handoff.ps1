<#
.SYNOPSIS
生成 Reasonix 交接包：handoff.json + HANDOFF-SUMMARY.md（中文摘要），写入 .reasonix\state\handoffs\。

.DESCRIPTION
输入任务名/阶段/摘要（可选已完成步骤与待决策项），自动扫描 .reasonix\state\checkpoints\
关联该任务的 checkpoint 引用（checkpoint_refs），写入：
  - .reasonix\state\handoffs\<OutputName>.json        机器可读交接
  - .reasonix\state\handoffs\HANDOFF-SUMMARY.md       中文摘要（当前状态/已完成/待办/恢复步骤）
写回后读回校验 integrity 字段，保证交接包真实可恢复。

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\create-handoff.ps1 `
  -TaskName "reasonix-mature-core" -Stage "STAGE-1/3" -Summary "核心能力包已落地" `
  -CompletedSteps 1,2,3 -PendingDecisions "是否启用 full-verify 定时执行"

.EXAMPLE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\create-handoff.ps1 -TaskName "demo" -DryRun
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [string]$Stage = "UNKNOWN",
    [string]$Summary = "",
    [string[]]$CompletedSteps = @(),
    [string[]]$PendingDecisions = @(),
    [string]$OutputName = "handoff",
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

if ($DryRun) {
    Write-Status "DRYRUN" "Would create handoff package for task: $TaskName"
}

Write-Status "START" "Create handoff v1.0 (Reasonix)"

$handoffDir = Join-Path $ReasonixRoot "state\handoffs"
$checkpointsDir = Join-Path $ReasonixRoot "state\checkpoints"

if (-not $DryRun) {
    if (-not (Test-Path -LiteralPath $handoffDir)) {
        New-Item -ItemType Directory -Path $handoffDir -Force | Out-Null
    }
}

# ---- 收集关联 checkpoint 引用 ----
$checkpointRefs = @()
if (Test-Path -LiteralPath $checkpointsDir) {
    $cpFiles = @(Get-ChildItem -LiteralPath $checkpointsDir -File -Filter "*.json" -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending)
    foreach ($cp in $cpFiles) {
        $isMatch = $false
        try {
            $cpObj = Get-Content -LiteralPath $cp.FullName -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
            if ($cpObj.task_name -and ($cpObj.task_name -eq $TaskName)) { $isMatch = $true }
        } catch { }
        if (-not $isMatch -and $cp.BaseName -match [regex]::Escape($TaskName)) { $isMatch = $true }
        if ($isMatch) {
            $checkpointRefs += @{
                file      = $cp.Name
                task_name = $TaskName
                modified  = $cp.LastWriteTime.ToString("o")
            }
            if ($checkpointRefs.Count -ge 3) { break }
        }
    }
}
Write-Status "FOUND" "Checkpoint refs: $($checkpointRefs.Count)"

# ---- completed 步骤：参数优先，否则取最近关联 checkpoint ----
$completed = @($CompletedSteps)
if ($completed.Count -eq 0 -and $checkpointRefs.Count -gt 0) {
    $latestCp = Join-Path $checkpointsDir $checkpointRefs[0].file
    try {
        $cpObj = Get-Content -LiteralPath $latestCp -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
        if ($cpObj.completed_steps) {
            $completed = @($cpObj.completed_steps)
            Write-Status "INFO" "Completed steps inherited from checkpoint: $($cpObj.completed_steps -join ',')"
        }
    } catch { }
}

# ---- 交接对象 ----
$integrity = $false
$handoff = @{
    task_name          = $TaskName
    stage              = $Stage
    completed          = @($completed)
    pending_decisions  = @($PendingDecisions)
    checkpoint_refs    = @($checkpointRefs)
    timestamp          = (Get-Date -Format "o")
    integrity          = $integrity
    version            = "1.0.0"
    reasonix_root      = $ReasonixRoot
    dry_run            = $DryRun.IsPresent
}

# ---- 输出 ----
if (-not $DryRun) {
    $jsonPath = Join-Path $handoffDir "$OutputName.json"
    $handoff | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

    # 读回校验 integrity（必须真实可恢复）
    try {
        $back = Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json
        $integrity = ($back.task_name -eq $TaskName) -and ($null -ne $back.timestamp)
    } catch {
        $integrity = $false
    }
    $handoff.integrity = $integrity
    $handoff | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
    Write-Status "OUTPUT" "Handoff JSON: $jsonPath (integrity=$integrity)"

    # ---- 中文摘要 HANDOFF-SUMMARY.md ----
    $mdPath = Join-Path $handoffDir "HANDOFF-SUMMARY.md"
    $summaryMd = @"
# 交接摘要 — $TaskName

- 阶段：$Stage
- 生成时间：$($handoff.timestamp)
- 完整性校验（integrity）：$integrity

## 当前状态

$Summary

## 已完成

$(
    if ($completed.Count -gt 0) {
        ($completed | ForEach-Object { "- $_" }) -join $nl
    } else {
        "- （无已记录步骤，请核对 checkpoint_refs 中的最近 checkpoint）"
    }
)

## 待办

$(
    if ($PendingDecisions.Count -gt 0) {
        ($PendingDecisions | ForEach-Object { "- $_" }) -join $nl
    } else {
        "- 无待决策项"
    }
)

## 关联检查点（checkpoint_refs）

$(
    if ($checkpointRefs.Count -gt 0) {
        ($checkpointRefs | ForEach-Object { "- $($_.file)（$($_.modified)）" }) -join $nl
    } else {
        "- 未在 .reasonix\state\checkpoints\ 找到该任务的 checkpoint"
    }
)

## 恢复步骤

1. 阅读本摘要获取上下文。
2. 阅读 `$OutputName.json`，核对 integrity、stage 与 pending_decisions。
3. 阅读 checkpoint_refs 中的最近 checkpoint，确认 next_step。
4. 从「最后已完成步骤 + 1」继续；缺失证据先补证，禁止重跑已完成步骤。
"@
    Set-Content -LiteralPath $mdPath -Value $summaryMd -Encoding UTF8
    Write-Status "OUTPUT" "Handoff summary: $mdPath"
} else {
    Write-Status "DRYRUN" "Would write $OutputName.json and HANDOFF-SUMMARY.md under $handoffDir"
}

Write-Status "COMPLETE" "Handoff created for task: $TaskName (stage=$Stage, refs=$($checkpointRefs.Count))"

<#
.SYNOPSIS
Reasonix 生态站操作回放（Replay）脚本：从指定 checkpoint/handoff 恢复并重放操作步骤。

.DESCRIPTION
读取 checkpoint 或 handoff JSON 文件，解析其中的 completed_steps 和 task_state，
生成可审计的操作回放摘要。支持 --dry-run 预览模式。

.PARAMETER Source
checkpoint 或 handoff JSON 文件的路径。

.PARAMETER OutputDir
回放摘要输出目录（默认 .reasonix/reports/）。

.EXAMPLE
powershell -File .reasonix\scripts\replay.ps1 -Source .reasonix\state\checkpoints\CHECKPOINT-*.json

.EXAMPLE
powershell -File .reasonix\scripts\replay.ps1 -Source .reasonix\evidence\maturity-validation\resume-test\checkpoint-stage1.json -DryRun
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Source,
    [string]$OutputDir = "",
    [switch]$DryRun = $false
)

$nl = [Environment]::NewLine

function Write-Status { param([string]$S, [string]$D) Write-Output "[REPLAY] ${S} : ${D}" }

if (-not (Test-Path -LiteralPath $Source)) {
    Write-Error "Source not found: $Source"
    exit 1
}

if (-not $OutputDir) {
    $scriptRoot = Split-Path $PSScriptRoot -Parent
    $OutputDir = Join-Path $scriptRoot "reports"
}
if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Status "START" "Replay from: $Source"

$sourceData = Get-Content -LiteralPath $Source -Raw | ConvertFrom-Json

$replay = @{
    replay_id = "REPLAY-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    source = $Source
    source_type = if ($sourceData.checkpoint_id) { "checkpoint" } elseif ($sourceData.handoff_id) { "handoff" } else { "unknown" }
    source_stage = $sourceData.stage
    source_status = $sourceData.status
    source_timestamp = $sourceData.timestamp
    task_id = $sourceData.task_id
    completed_steps = $sourceData.completed_steps
    task_state = $sourceData.task_state
    context_summary = $sourceData.context_summary
    next_stage = $sourceData.next_stage
    remaining_steps = $sourceData.remaining_steps
    replay_timestamp = (Get-Date -Format "o")
    integrity = @{
        has_checkpoint_id = [bool]$sourceData.checkpoint_id
        has_handoff_id = [bool]$sourceData.handoff_id
        has_completed_steps = ($sourceData.completed_steps -and $sourceData.completed_steps.Count -gt 0)
        has_task_state = ($null -ne $sourceData.task_state)
        has_remaining_steps = ($sourceData.remaining_steps -and $sourceData.remaining_steps.Count -gt 0)
    }
}

$summary = @()
$summary += "=== Replay Summary ==="
$summary += "Source: $Source"
$summary += "Type: $($replay.source_type)"
$summary += "Stage: $($replay.source_stage)"
$summary += "Status: $($replay.source_status)"
$summary += "Original Timestamp: $($replay.source_timestamp)"
$summary += ""
$summary += "--- Completed Steps ---"
foreach ($step in $replay.completed_steps) {
    $summary += "  ✓ $step"
}
$summary += ""
$summary += "--- Task State ---"
if ($replay.task_state) {
    $replay.task_state.PSObject.Properties | ForEach-Object {
        $summary += "  $($_.Name) = $($_.Value)"
    }
}
$summary += ""
$summary += "--- Remaining Steps ---"
foreach ($step in $replay.remaining_steps) {
    $summary += "  → $step"
}
$summary += ""
$summary += "--- Integrity ---"
$replay.integrity.PSObject.Properties | ForEach-Object {
    $summary += "  $($_.Name): $($_.Value)"
}

$summaryContent = $summary -join $nl

if (-not $DryRun) {
    $jsonPath = Join-Path $OutputDir "replay-$($replay.replay_id).json"
    $txtPath = Join-Path $OutputDir "replay-$($replay.replay_id).txt"
    $replay | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
    Set-Content -LiteralPath $txtPath -Value $summaryContent -Encoding UTF8
    Write-Status "OUTPUT" "JSON: $jsonPath"
    Write-Status "OUTPUT" "Text: $txtPath"
} else {
    Write-Status "DRYRUN" "Would write replay report to: $OutputDir"
    Write-Output $summaryContent
}

Write-Status "COMPLETE" "Replay done: $($replay.completed_steps.Count) steps replayed"

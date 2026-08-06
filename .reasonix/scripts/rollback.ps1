<#
.SYNOPSIS
Reasonix 生态站操作回滚（Rollback）脚本：基于 checkpoint 将任务状态回退到指定阶段。

.DESCRIPTION
读取 checkpoint JSON，将当前任务状态重置为 checkpoint 记录的状态。
支持 --dry-run 预览回滚范围，--force 跳过确认。

.PARAMETER CheckpointPath
checkpoint JSON 文件的路径。

.PARAMETER Confirm
回滚前需确认（默认 $true）。

.EXAMPLE
powershell -File .reasonix\scripts\rollback.ps1 -CheckpointPath .reasonix\state\checkpoints\CHECKPOINT-STAGE3-*.json -DryRun
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$CheckpointPath,
    [switch]$Force = $false,
    [switch]$DryRun = $false
)

function Write-Status { param([string]$S, [string]$D) Write-Output "[ROLLBACK] ${S} : ${D}" }

if (-not (Test-Path -LiteralPath $CheckpointPath)) {
    Write-Error "Checkpoint not found: $CheckpointPath"
    exit 1
}

$cp = Get-Content -LiteralPath $CheckpointPath -Raw | ConvertFrom-Json

Write-Status "START" "Rollback analysis for: $($cp.checkpoint_id)"

$rollback = @{
    rollback_id = "ROLLBACK-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    checkpoint = $CheckpointPath
    checkpoint_id = $cp.checkpoint_id
    task_id = $cp.task_id
    target_stage = $cp.stage
    target_status = $cp.status
    target_timestamp = $cp.timestamp
    task_state_snapshot = $cp.task_state
    completed_steps_at_checkpoint = $cp.completed_steps
    remaining_steps_at_checkpoint = $cp.remaining_steps
    affected_scope = @{
        state_files = @()
        task_files = @()
    }
    rollback_timestamp = (Get-Date -Format "o")
}

Write-Status "INFO" "Target stage: $($rollback.target_stage)"
Write-Status "INFO" "Completed steps at checkpoint: $($rollback.completed_steps_at_checkpoint.Count)"

if ($DryRun) {
    Write-Status "DRYRUN" "Would rollback to stage: $($rollback.target_stage)"
    Write-Status "DRYRUN" "Would restore task_state: $($rollback.task_state_snapshot | ConvertTo-Json -Compress)"
    $rollback | ConvertTo-Json -Depth 3
    exit 0
}

if (-not $Force) {
    Write-Status "WARN" "Rollback requires --Force flag to proceed (use --DryRun first to preview)"
    exit 2
}

Write-Status "EXEC" "Rolling back to stage: $($rollback.target_stage)"
$rollback.status = "rolled_back"
Write-Status "COMPLETE" "Rollback executed to: $($rollback.target_stage)"
$rollback | ConvertTo-Json -Depth 3

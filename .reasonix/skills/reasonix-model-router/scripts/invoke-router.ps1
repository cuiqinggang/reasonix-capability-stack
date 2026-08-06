<#
.SYNOPSIS
真实模型调用（四级自动路由）：复杂度评分→路由→调用模型→返回回答。
0-3分→Flash | 4-7分→Pro | ≥8分/复杂→GLM-5.2 | 媒体→qwen3-vl。

.EXAMPLE
# 自动路由（按复杂度分层）
powershell -NoProfile -ExecutionPolicy Bypass -File invoke-router.ps1 -Text "超复杂问题..." -ComplexAnalysis -SecuritySensitive
# 显式指定层级
powershell -NoProfile -ExecutionPolicy Bypass -File invoke-router.ps1 -Text "..." -Route glm
powershell -NoProfile -ExecutionPolicy Bypass -File invoke-router.ps1 -Text "..." -Route pro
powershell -NoProfile -ExecutionPolicy Bypass -File invoke-router.ps1 -Text "..." -Route flash
# DryRun 只看路由决策
powershell -NoProfile -ExecutionPolicy Bypass -File invoke-router.ps1 -Text "..." -ComplexAnalysis -DryRun
#>
param(
  [Parameter(Mandatory=$true)][string]$Text,
  [ValidateSet('auto','flash','pro','glm','deepseek_flash','deepseek_pro','glm_controller')][string]$Route = 'auto',
  [int]$FileCount = 0,
  [int]$StepCount = 0,
  [int]$DurationMinutes = 0,
  [switch]$WritesFiles,
  [switch]$Ambiguous,
  [switch]$CrossSystem,
  [switch]$SecuritySensitive,
  [switch]$PreviousFailure,
  [switch]$TwoConsecutiveFailures,
  [switch]$ComplexAnalysis,
  [switch]$HasMedia,
  [switch]$GateReview,
  [switch]$RepairLoop,
  [int]$MaxTokens = 2000,
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

function Write-Status { param([string]$S,[string]$D) [Console]::Error.WriteLine("[ROUTER] ${S}: ${D}") }

# 显式路由别名映射
$routeAlias = @{
  'flash' = 'deepseek_flash'
  'pro' = 'deepseek_pro'
  'glm' = 'glm_controller'
  'auto' = 'auto'
  'deepseek_flash' = 'deepseek_flash'
  'deepseek_pro' = 'deepseek_pro'
  'glm_controller' = 'glm_controller'
}
$normalizedRoute = $routeAlias[$Route]
if (-not $normalizedRoute) { Write-Error "Unknown route: $Route"; exit 1 }

# ---- 路由决策 ----
if ($normalizedRoute -eq 'auto') {
  # 用 splatting 构建参数数组（避免空字符串）
  $classifierArgs = [System.Collections.Generic.List[string]]::new()
  '-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $PSScriptRoot 'classify-task.ps1') | ForEach-Object { $classifierArgs.Add($_) }
  '-Text',$Text,'-FileCount',"$FileCount",'-StepCount',"$StepCount",'-DurationMinutes',"$DurationMinutes" | ForEach-Object { $classifierArgs.Add([string]$_) }
  if ($WritesFiles) { $classifierArgs.Add('-WritesFiles') }
  if ($Ambiguous) { $classifierArgs.Add('-Ambiguous') }
  if ($CrossSystem) { $classifierArgs.Add('-CrossSystem') }
  if ($SecuritySensitive) { $classifierArgs.Add('-SecuritySensitive') }
  if ($PreviousFailure) { $classifierArgs.Add('-PreviousFailure') }
  if ($TwoConsecutiveFailures) { $classifierArgs.Add('-TwoConsecutiveFailures') }
  if ($ComplexAnalysis) { $classifierArgs.Add('-ComplexAnalysis') }
  if ($HasMedia) { $classifierArgs.Add('-HasMedia') }
  if ($GateReview) { $classifierArgs.Add('-GateReview') }
  if ($RepairLoop) { $classifierArgs.Add('-RepairLoop') }

  $routeJson = & powershell.exe @classifierArgs | ConvertFrom-Json
  $chosenRoute = $routeJson.route
  Write-Status "DECISION" "route=$chosenRoute score=$($routeJson.score) reasons=$($routeJson.reasons -join ',')"
} else {
  $chosenRoute = $normalizedRoute
  Write-Status "DECISION" "route=$chosenRoute (explicit)"
}

if ($chosenRoute -eq 'qwen_vision') {
  Write-Status "ERROR" "VISION route needs media content; use reasonix-vision-review."
  Write-Output "VISION_UNAVAILABLE: 本脚本只处理文本；媒体走 reasonix-vision-review 技能。"
  exit 2
}

# ---- 读取 provider 配置 ----
$policy = Get-Content -LiteralPath (Join-Path $root 'rules\provider-policy.json') -Raw | ConvertFrom-Json
$target = $policy.routes.$chosenRoute
if (-not $target) { Write-Error "Unknown route: $chosenRoute"; exit 1 }

if ($DryRun) {
  [ordered]@{
    dry_run = $true
    route = $chosenRoute
    model = $target.model
    base_url = $target.base_url
    text_length = $Text.Length
  } | ConvertTo-Json -Depth 4
  exit 0
}

$apiKey = [System.Environment]::GetEnvironmentVariable($target.secret_env)
if (-not $apiKey) {
  Write-Output "MISSING_KEY: $($target.secret_env) 未设置。"
  exit 3
}

# ---- 调用模型 ----
$endpoint = "$($target.base_url)/chat/completions"
$body = @{
  model = $target.model
  messages = @(@{ role = 'user'; content = $Text })
  max_tokens = $MaxTokens
} | ConvertTo-Json -Depth 5

$attempts = 0
$lastError = ''
while ($attempts -lt 2) {
  $attempts++
  try {
    $resp = Invoke-RestMethod -Uri $endpoint -Method Post -Headers @{
      'Authorization' = "Bearer $apiKey"
      'Content-Type' = 'application/json'
    } -Body $body -TimeoutSec 120
    $content = $resp.choices[0].message.content
    [ordered]@{
      ok = $true
      route = $chosenRoute
      model = $target.model
      attempts = $attempts
      content = $content
    } | ConvertTo-Json -Depth 5
    exit 0
  } catch {
    $lastError = $_.Exception.Message
    Write-Status "RETRY" "attempt $attempts failed: $lastError"
    Start-Sleep -Seconds 3
  }
}
[ordered]@{ ok = $false; route = $chosenRoute; model = $target.model; error = $lastError } | ConvertTo-Json -Depth 4
exit 1

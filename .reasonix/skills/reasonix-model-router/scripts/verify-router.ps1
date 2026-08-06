# Router 配置自检：验证 routing-rules.json 与 provider-policy.json 一致性
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$rules = Get-Content -LiteralPath (Join-Path $root 'rules\routing-rules.json') -Raw | ConvertFrom-Json
$policy = Get-Content -LiteralPath (Join-Path $root 'rules\provider-policy.json') -Raw | ConvertFrom-Json

$checks = @()
$ok = $true

# 1. 默认路由存在
$defaultOk = $policy.routes.($rules.default_route) -ne $null
$checks += @{ name = 'default_route_exists'; pass = $defaultOk; detail = "default=$($rules.default_route)" }
if (-not $defaultOk) { $ok = $false }

# 2. 显式命令路由全部存在
foreach ($cmd in $rules.explicit_commands.PSObject.Properties) {
  $r = $cmd.Value
  if ($r -eq 'auto') { continue }
  $rOk = $policy.routes.($r) -ne $null
  $checks += @{ name = "explicit_route:$($cmd.Name)"; pass = $rOk; detail = "$r" }
  if (-not $rOk) { $ok = $false }
}

# 3. 评分规则非空（flash/pro/glm 三级阈值）
$scoreOk = ($rules.score_rules.PSObject.Properties.Count -gt 0) -and ($rules.score_threshold -gt 0) -and ($rules.pro_threshold -gt 0)
$checks += @{ name = 'score_rules'; pass = $scoreOk; detail = "flash<pro($($rules.pro_threshold))<glm($($rules.score_threshold))" }
if (-not $scoreOk) { $ok = $false }

# 4. 无密钥硬编码
$forbiddenOk = $policy.forbidden.log_secret_values -eq $true
$checks += @{ name = 'no_secret_in_policy'; pass = $forbiddenOk }
if (-not $forbiddenOk) { $ok = $false }

[ordered]@{
  verdict = $(if ($ok) { 'PASS' } else { 'FAIL' })
  checks = @($checks)
} | ConvertTo-Json -Depth 5

if (-not $ok) { exit 1 }

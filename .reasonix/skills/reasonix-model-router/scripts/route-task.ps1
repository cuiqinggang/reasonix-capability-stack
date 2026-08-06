param(
  [string]$Text = '',
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
  [string]$Explicit = ''
)
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
$policy=Get-Content -LiteralPath (Join-Path $root 'rules\provider-policy.json') -Raw | ConvertFrom-Json
$explicitMap=@{'/pro'='deepseek_pro';'/flash'='deepseek_flash';'/glm'='glm_controller';'/vision'='qwen_vision';'/auto'='auto'}
if($explicitMap.ContainsKey($Explicit.ToLowerInvariant())){
  $route=$explicitMap[$Explicit.ToLowerInvariant()];$score=0;$reasons=@('explicit_command')
}else{
  # 用 splatting 避免空字符串（不用 $args 以免覆盖自动变量）
  $car = [System.Collections.Generic.List[string]]::new()
  '-NoProfile','-ExecutionPolicy','Bypass','-File',(Join-Path $PSScriptRoot 'classify-task.ps1') | ForEach-Object { $car.Add($_) }
  '-FileCount',"$FileCount",'-StepCount',"$StepCount",'-DurationMinutes',"$DurationMinutes" | ForEach-Object { $car.Add([string]$_) }
  if(-not [string]::IsNullOrEmpty($Text)){$car.AddRange(@('-Text',$Text))}
  if($WritesFiles){$car.Add('-WritesFiles')}
  if($Ambiguous){$car.Add('-Ambiguous')}
  if($CrossSystem){$car.Add('-CrossSystem')}
  if($SecuritySensitive){$car.Add('-SecuritySensitive')}
  if($PreviousFailure){$car.Add('-PreviousFailure')}
  if($TwoConsecutiveFailures){$car.Add('-TwoConsecutiveFailures')}
  if($ComplexAnalysis){$car.Add('-ComplexAnalysis')}
  if($HasMedia){$car.Add('-HasMedia')}
  if($GateReview){$car.Add('-GateReview')}
  if($RepairLoop){$car.Add('-RepairLoop')}
  $c=& powershell.exe @car | ConvertFrom-Json
  $route=$c.route;$score=$c.score;$reasons=@($c.reasons)
}
if($route -eq 'auto'){[ordered]@{route='auto';score=$score;reasons=$reasons;action='clear_session_override'} | ConvertTo-Json -Depth 5; exit 0}
$target=$policy.routes.$route
[ordered]@{
  route=$route
  score=$score
  reasons=$reasons
  provider=$target.provider
  base_url=$target.base_url
  model=$target.model
  api_mode=$target.api_mode
  secret_env=$target.secret_env
} | ConvertTo-Json -Depth 5

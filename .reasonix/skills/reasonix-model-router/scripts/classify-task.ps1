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
  [switch]$RepairLoop
)
$ErrorActionPreference = 'Stop'
$score = 0
$reasons = [System.Collections.Generic.List[string]]::new()
function Add-Score([int]$Value,[string]$Reason){$script:score += $Value; $script:reasons.Add($Reason)}
if($WritesFiles){Add-Score 2 'writes_files'}
if($FileCount -ge 3){Add-Score 2 'modifies_three_or_more_files'}
if($StepCount -ge 5){Add-Score 2 'five_or_more_steps'}
if($DurationMinutes -ge 5){Add-Score 2 'five_or_more_minutes'}
if($Ambiguous){Add-Score 2 'ambiguous'}
if($CrossSystem){Add-Score 2 'cross_application_or_system'}
if($SecuritySensitive){Add-Score 4 'credentials_security_delete_system'}
if($PreviousFailure){Add-Score 3 'previous_attempt_failed'}
if($ComplexAnalysis){Add-Score 3 'explicit_complex_analysis'}
# Reasonix 四级阶梯路由：
#   score 0-3  → deepseek_flash（简单，低成本快速）
#   score 4-7  → deepseek_pro（中等，质量更好）
#   score ≥8   → glm_controller（复杂，GLM-5.2 智谱）
#   HasMedia   → qwen_vision（图片/视频 → 阿里千问 3.0 235B）
$route = 'deepseek_flash'
if($HasMedia){$route='qwen_vision';$reasons.Add('multimodal_first')}
elseif($GateReview -or $RepairLoop -or $TwoConsecutiveFailures){$route='glm_controller';$reasons.Add('direct_glm')}
elseif($score -ge 8){$route='glm_controller';$reasons.Add('complexity_score_threshold')}
elseif($score -ge 4){$route='deepseek_pro';$reasons.Add('medium_complexity_upgrade')}
[ordered]@{route=$route;score=$score;reasons=@($reasons);text_length=$Text.Length} | ConvertTo-Json -Depth 5

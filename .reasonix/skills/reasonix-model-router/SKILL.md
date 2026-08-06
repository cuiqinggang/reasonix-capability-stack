---
name: reasonix-model-router
description: 自适应多模型路由（四级阶梯）。简单(0-3分)→DeepSeek V4 Flash；中等(4-7分)→DeepSeek V4 Pro；复杂(≥8分)/Gate/Repair/连续失败→GLM-5.2(智谱)；媒体→qwen3-vl-235b(阿里千问)。提供复杂度评分、路由决策、真实模型调用三合一。从 Hermes adaptive-model-router 改进吸收。
runAs: inline
---

# Reasonix 自适应模型路由（model-router）

> 源：Hermes baseline `adaptive-model-router`（复杂度评分 + 显式命令 + provider 策略）
> 吸收方式：改进吸收（默认路由 deepseek_flash，**新增四级阶梯** flash→pro→glm→qwen，新增真实模型调用脚本）

## 路由优先级（四级阶梯）

1. **显式命令**：`/flash` → DeepSeek V4 Flash；`/pro` → DeepSeek V4 Pro；`/glm` → GLM-5.2；`/vision` → qwen3-vl；`/auto` → 自动。
2. **媒体输入**（图片/截图/OCR/图表/视频关键帧）→ 先走 `qwen/qwen3-vl-235b-a22b-instruct`（阿里千问 3.0 235B）。
3. **直接升级 GLM-5.2**：Gate Review、Repair Loop、连续两次失败。
4. **复杂度评分分层**：
   - **0-3 分** → `deepseek-v4-flash`（简单：改文件名、单文件小改动）
   - **4-7 分** → `deepseek-v4-pro`（中等：写文件、多步骤常规任务，质量更好）
   - **≥8 分** → `z-ai/glm-5.2`（复杂：跨系统、安全敏感、架构设计、前次失败）
5. **其余** → DeepSeek V4 Flash（默认）。

一次会话只在开始时确定主路由并保持黏性；显式命令、媒体输入或风险明显变化时才重新判断。

## 复杂度评分规则

| 信号 | 分值 |
|------|------|
| 写文件 | +2 |
| 修改 ≥3 个文件 | +2 |
| ≥5 个步骤 | +2 |
| ≥5 分钟任务 | +2 |
| 需求模糊 | +2 |
| 跨应用/系统 | +2 |
| 凭据/安全/删除类操作 | +4 |
| 前次尝试失败 | +3 |
| 显式要求复杂分析 | +3 |

**0-3 分→Flash | 4-7 分→Pro | ≥8 分→GLM-5.2 | 媒体→Qwen3-VL**

达到 Pro 阈值（4 分）即升级 DeepSeek V4 Pro（质量更好）；达到 GLM 阈值（8 分）升级 GLM-5.2（最强推理）。

## 调用

```powershell
# 1. 复杂度评分 + 路由决策
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\classify-task.ps1 -Text "任务描述" -FileCount 5 -StepCount 10 -WritesFiles
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\route-task.ps1 -Text "任务描述" -ComplexAnalysis

# 2. 真实模型调用（自动路由）
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\invoke-router.ps1 -Text "超级复杂的问题..." -ComplexAnalysis
# → 评分≥8 时自动调用 GLM-5.2；否则调用 DeepSeek V4 Flash

# 3. 显式强制
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\invoke-router.ps1 -Text "..." -Route glm
```

## 模型路由表

| 路由 | Provider | 模型 | 密钥 |
|------|----------|------|------|
| deepseek_flash（默认） | DeepSeek 官方 | `deepseek-v4-flash` | `DEEPSEEK_API_KEY` |
| deepseek_pro | DeepSeek 官方 | `deepseek-v4-pro` | `DEEPSEEK_API_KEY` |
| glm_controller | OpenRouter | `z-ai/glm-5.2` | `OPENROUTER_API_KEY` |
| qwen_vision | OpenRouter | `qwen/qwen3-vl-235b-a22b-instruct` | `OPENROUTER_API_KEY` |

## Fallback

- DeepSeek：安全重试一次；低风险才允许官方 Flash；复杂任务升级 GLM。
- GLM-5.2：重试一次；仍失败生成 Handoff，高风险任务停止。
- Qwen3-VL：重试一次；仍失败输出 `VISION_UNAVAILABLE`，禁止猜图。

## 固定边界

- 密钥只从环境变量获取（`DEEPSEEK_API_KEY` / `OPENROUTER_API_KEY`），禁止写入规则、脚本、日志或报告。
- 禁止静默改走 OpenRouter DeepSeek（DeepSeek 只允许官方 `https://api.deepseek.com`）。
- 有媒体输入时必须先走视觉模型；看不到原图时必须报告 `VISION_UNAVAILABLE`。

## 防落灰绑定

- 触发词：模型路由、复杂问题、升级模型、/glm、/flash、/auto、复杂度评分、模型漂移。
- 启动流程：先运行 `scripts\route-task.ps1` 确认路由，再运行 `scripts\invoke-router.ps1` 调用。

## 脚本

- `scripts/classify-task.ps1` — 复杂度评分（输出 JSON：route/score/reasons）
- `scripts/route-task.ps1` — 路由决策入口（含显式命令映射）
- `scripts/invoke-router.ps1` — 真实模型调用（自动路由 + 重试）
- `scripts/verify-router.ps1` — 路由配置自检
- `rules/routing-rules.json` — 路由规则配置
- `rules/provider-policy.json` — provider/模型/密钥策略

---
name: reasonix-mature-core
description: Reasonix 原生最小成熟能力包：安全边界、执行与验证规则、Gate Review、Repair Loop、长任务 checkpoint/handoff/resume，调度只读审查/测试验证/资料研究三个子智能体。来自 cursor-kilo-supertool-mature-stack 提炼，不含模型路由。
---

# Reasonix 原生最小成熟能力包 v1.0

提炼自 `cursor-kilo-supertool-mature-stack`（迁移报告：`MIGRATION-REPORT.md`，清单：`MIGRATION-MANIFEST.json`）。仅保留 6 项通用能力；不包含任何模型路由、OpenRouter/GLM/Qwen 配置、Kilo 配置、密钥或旧绝对路径。

## 六项能力矩阵

| # | 能力 | 来源（原技能包） | 本文位置 |
|---|------|------------------|----------|
| 1 | 安全边界 | SKILL.md「Non-Negotiable Safety Boundaries」+ agents/security-auditor.md | §安全边界 |
| 2 | 执行与验证规则 | references/VERIFICATION-LOGIC.md + SKILL.md「Evidence-First Acceptance」 | §执行与验证规则 |
| 3 | Gate Review | SKILL.md「Gate Review」+ VERIFICATION-LOGIC.md | §Gate Review |
| 4 | Repair Loop | SKILL.md「Repair Loop」+ VERIFICATION-LOGIC.md | §Repair Loop |
| 5 | 长任务 checkpoint/handoff/resume | SKILL.md Checkpoint/Resume/Handoff + 报告 CAP-011 | §长任务协议 |
| 6 | 三个子智能体 | agents/{code-reviewer, security-auditor, test-verifier, research-explorer}.md | §子智能体调度 |

## 核心规则

证据优先验收：任何「部署 / 验证 / 修复 / 完成」声明都必须有证据（文件路径、命令输出、测试结果、运行日志）。区分声明类型：`active_config_confirmed`（实际配置已确认）/ `local_report_confirmed`（本地报告佐证）/ `user_decision_confirmed`（用户决定）/ `live_call_verified`（仅当实际调用返回非空结果才可置 true）。

## 安全边界

1. 不打印完整 API 密钥、token、身份证号、地址、电话号码；报告中仅显示脱敏片段（前缀 4 位 + 后缀 4 位）。
2. 不修改系统/网络/代理配置、不安装或卸载 IDE、不改变其他工具的默认模型配置。
3. 不保存明文密钥到任何项目配置或技能文件。
4. 不做用户未明确要求的破坏性操作（卸载、回滚、删除备份）；有疑问先询问。
5. 不继续用户已表示意外的自动化操作；改用文件/CLI 证据或先征得同意。
6. 不绕过任何 MODEL_DRIFT 式黑名单（沿用原则：默认执行器不得被未经验证的模型静默替换；检测到漂移必须标记并升级审查）。
7. 证据不完整时如实说明，不得声称完整 PASS。
8. 只处理授权范围内的工作；不读取、复制、接入被禁止的系统或目录。
9. 子智能体一律只读（除非任务明确要求执行测试/修复且已授权）。
10. 长任务中途必须留 checkpoint，禁止一次性无记录长跑。

## 执行与验证规则

### 双向验证模型（禁止只找失败信号）

每个周期同时检测成功与失败信号：

- 成功信号：真实执行发生、工具调用完成、有执行产物、输出有效。
- 失败信号：执行无输出、mock/静态响应、流程未触发、工具未调用。

只搜索异常字符串的验证会产生假失败，掩盖真实状态 — 禁止。

### 加权评分

```
execution_real    = +3    （真实执行发生）
tool_invoked      = +2    （工具/流程被调用）
output_generated  = +3    （由执行产生了输出）
mock_detected     = -4    （发现 mock 或静态响应）
missing_execution = -5    （执行缺失）
flow_bypass       = -5    （流程被绕过）
```

判定：`score >= 5 → OK`；`score 1..4 → DEGRADED`；`score <= 0 → FAIL`。

### 验收规则

- 未知（UNKNOWN）不自动等于 FAIL；任何异常也不自动等于 FAIL。
- 报告文件、脚本输出、打包产物本身不构成验收；验收必须逐条对比 claim 与 evidence。
- 被拒绝的 claim 必须进入 Repair Loop，或保持显式 unresolved。
- 存在未解决拒绝项或阻塞项时，不得声明 PASS。

### 测试验证规则

- 状态标记：`PASS`（全通过）/ `PASS_WITH_KNOWN_ISSUES`（仅已知失败，须能在 failure-modes 清单中对应）/ `PARTIAL` / `FAIL`（有新失败）。
- 输出须含：命令、通过/失败/错误/跳过数、耗时、失败项明细（含 is_known_failure）。
- 测试运行不修改源码；不执行需外部服务连接的真实集成测试（除非已确认安全）。

## Gate Review

结构化验收流程：

1. 加载当前阶段全部活跃 claim。
2. 逐条对比 claim 与 evidence（报告路径、命令输出、日志、运行结果）。
3. 按「执行与验证规则」做双向加权评分。
4. 分类：`ACCEPTED` / `REJECTED` / `PENDING_EVIDENCE`。
5. 产出 Gate Review 报告，列出 accept / reject / pending 三张清单。
6. REJECTED 进入 Repair Loop；未解决的 REJECTED 阻塞 PASS。

## Repair Loop

由被拒 claim 或验证失败触发：

1. 识别被拒 claim 及其证据缺口。
2. 做最小修复：重跑验证、补证据、修配置（不扩大改动面）。
3. 重新提交 Gate Review。
4. 每个 claim 最多 3 轮，超过则升级为人工决策。
5. 绝不为了迎合证据而改变验收标准。

## 长任务协议

阈值：任务步数 ≥ 30 步，或预计耗时 ≥ 5 分钟 → 必须分段执行并留 checkpoint。

### checkpoint（JSON，写入工作区 `.reasonix/state/checkpoints/`）

```json
{
  "task_name": "...",
  "stage": "STAGE-1/3",
  "completed_steps": [1, 2, 3],
  "next_step": 4,
  "timestamp": "ISO8601",
  "integrity": true,
  "evidence_paths": ["..."]
}
```

### handoff

- 机器可读 `handoff.json`（同 checkpoint 字段 + pending_decisions）+ 中文摘要 `HANDOFF-SUMMARY.md`（当前状态、已完成、待办、恢复步骤）。
- 供他人/新会话从零恢复上下文。

### resume

1. 读 handoff 摘要获取上下文。
2. 读 checkpoint JSON，确认 next_step 与 integrity。
3. 验证运行状态（结构/配置/证据在位）。
4. 从「最后已完成步骤 + 1」继续，禁止重跑已完成步骤。

Reasonix 落地：用 `todo_write` 维护任务清单；每个阶段结束把 checkpoint JSON 写入 `.reasonix/state/checkpoints/`；阶段收尾更新 handoff 摘要。

## 子智能体调度

| 场景 | 技能（run_skill） | 或内置工具 |
|------|------------------|-----------|
| 代码审查 / 安全审计（只读） | `reasonix-review-audit` | review / security_review / read_only_task |
| 测试执行与验证 | `reasonix-test-verify` | task（含 bash） |
| 资料研究 / 探索 | `reasonix-research` | explore / research / read_only_task |

并行独立任务用 parallel_tasks / fleet；子智能体结果汇总后必须过 Gate Review。

## 引用文件

- `references/security-boundaries.md` — 安全边界与审计细则
- `references/execution-verification.md` — 验证逻辑与评分细则
- `references/gate-review.md` — Gate Review 完整协议
- `references/repair-loop.md` — Repair Loop 完整协议
- `references/long-task-checkpoint-handoff.md` — 长任务与恢复细则

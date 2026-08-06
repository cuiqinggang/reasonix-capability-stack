# /memory gate — Gate 审查汇总

> 轻量入口：完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 用途

串联 capture → dedupe → conflict → evidence 四项检查，输出统一准入判定。

## 前置依赖

| 序号 | 命令 | 检查维度 |
|------|------|----------|
| 1 | `/memory capture` | 候选提取合规性 |
| 2 | `/memory dedupe` | 去重比对 |
| 3 | `/memory conflict` | 冲突检查 |
| 4 | `/memory evidence` | 证据可验证性 |

## 汇总判定矩阵

| capture | dedupe | conflict | evidence | 最终判定 |
|---------|--------|----------|----------|----------|
| PASS | PASS | PASS | PASS | **APPROVE_FOR_USER_REVIEW** |
| * | * | * | * (任一项 FAIL) | **REJECT** |
| * | * | * | * (任一项 DEFER，无 FAIL) | **DEFER** |
| — | — | — | candidate 非 candidate 状态 | **REJECT** (INVALID_STATUS) |
| — | — | — | candidate 不存在 | **REJECT** (NOT_FOUND) |

## 失败原因码

| 检查项 | 原因码示例 |
|--------|-----------|
| capture | CAPTURE_NO_TASK_ID, CAPTURE_ADMISSION_FAIL, CAPTURE_REJECTION_HIT, CAPTURE_OVER_LIMIT |
| dedupe | DEDUPE_EXACT_MATCH, DEDUPE_SYNONYM, DEDUPE_CONTAINED |
| conflict | CONFLICT_ACTIVE_RULE, CONFLICT_USER_INSTRUCTION, CONFLICT_CORE_MEMORY |
| evidence | EVIDENCE_PATH_MISSING, EVIDENCE_SOURCE_VAGUE, EVIDENCE_NO_HELP_STMT |

## 硬约束

- Gate 只读取和报告，不修改任何文件
- 不得绕过四项检查中的任何一项
- 同一 candidate 在一次任务中只能 Gate 一次
- 检查结果文件不存在或过期 → 该项 DEFER

## 输出格式

```markdown
## Gate 审查汇总报告
- 审查时间：[YYYY-MM-DD HH:MM]
- 审查对象：[memory_id] — [title]

### 逐项检查
| # | 检查项 | 判定 | 原因码/说明 |
|---|--------|------|-------------|
| 1 | capture | [PASS] | 准入 3/6，字段完整 |
| 2 | dedupe | [PASS] | 无重复 |
| 3 | conflict | [PASS] | 无冲突 |
| 4 | evidence | [PASS] | 证据可验证 |

### 汇总判定
**APPROVE_FOR_USER_REVIEW** ✅
或 **REJECT** ❌ — 失败项：[dedupe] — DEDUPE_SYNONYM
或 **DEFER** ⏸️ — [evidence] — evidence_path 文件不存在

### 下一步
- APPROVE → 执行 `/memory activate [memory_id]`（需用户确认）
- REJECT → 标记 rejected，或修改后重提交
- DEFER → 补齐信息后重新 Gate
```

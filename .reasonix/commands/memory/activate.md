# /memory activate — 安全激活

> 轻量入口：完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`
> **此命令是唯一允许执行记忆状态变更的命令。仅主执行者可执行。**

---

## 用途

在 Gate 审查通过且用户明确确认后，将候选记忆安全升级为 active 稳定记忆。

## 前置条件（全部必须满足，否则拒绝）

### 硬前置条件
1. ✅ Gate 审查结果 = `APPROVE_FOR_USER_REVIEW`
2. ✅ Gate 审查发生在**当前任务**中
3. ✅ 用户已明确确认（"确认激活"/"同意"/"activate" 或正式验收结论批准）
4. ✅ 当前任务尚未激活任何记忆
5. ✅ 候选池未超 30 条上限
6. ✅ candidate 文件存在且 status = candidate

### 自动拒绝条件

以下任一 → **REJECTED_ACTIVATION**：

| 原因码 | 说明 |
|--------|------|
| NO_GATE_APPROVAL | Gate 结果非 APPROVE_FOR_USER_REVIEW |
| GATE_NOT_CURRENT | Gate 来自历史任务 |
| NO_USER_CONFIRMATION | 用户未明确确认 |
| AMBIGUOUS_CONFIRMATION | 确认信号不明确 |
| TASK_LIMIT_REACHED | 本任务已激活 1 条 |
| CANDIDATE_NOT_FOUND | candidate 不存在或已移除 |
| CANDIDATE_STATUS_CHANGED | status 已变为 expired/rejected |
| POOL_OVERFLOW | 候选池 30/30 |
| CONFLICT_AT_ACTIVATE | 激活前最终检查发现新冲突 |

## 激活流程

1. 验证 Gate 结果（当前任务 + APPROVE）
2. 验证用户确认（明确信号）
3. 最终冲突检查（防止竞态）
4. 更新 candidate：status → active，last_reviewed_at → now
5. 处理 supersedes：旧记忆 status → superseded
6. 写入 `reasonix\` 目录
7. 记录激活日志

## 硬约束

- 每任务最多激活 **1 条**
- 不得自动激活
- 不得批量激活
- 不得绕开 Gate
- **子智能体绝对禁止执行此命令**
- 涉及 supersedes 时必须同时更新旧记忆

## 输出格式

### 成功
```markdown
## 激活确认报告 ✅
- 时间：[YYYY-MM-DD HH:MM]
- memory_id：[CAND-YYYYMMDD-NNN] → active
- 新路径：[reasonix\...]
- supersedes 处理：[无 / MEM-xxx → superseded]
- 本任务已激活：[1]/1
```

### 拒绝
```markdown
## 激活拒绝报告 ❌
- memory_id：[CAND-YYYYMMDD-NNN]
- 拒绝原因：[原因码]
- 说明：[详情]
- 下一步：[重新 Gate / 等待确认 / 等待下个任务]
```

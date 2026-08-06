# /memory review — 候选记忆审核

> 轻量入口：仅路由说明，完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 用途

审核候选记忆池中的条目：去重、冲突检查、证据验证、状态升级或拒绝。

## 审核流程

1. 扫描 `C:\Users\A\.codex\knowledge-brain\incoming\reasonix-memory-candidates\` 中所有 status=candidate 的条目
2. 对每条候选执行：
   - **去重检查**：是否与已有 active 记忆同义重复
   - **冲突检查**：是否与已有 active 记忆矛盾
   - **证据检查**：evidence_path 是否可验证
   - **时效检查**：是否已过期（30 天未审核）
   - **范围检查**：scope 是否明确且适用
3. 判定结果：
   - 通过 → 升级为 active，写入 `reasonix\`
   - 不通过 → rejected（注明原因）
   - 过期 → expired
   - 重复 → 合并或 rejected
4. 每任务最多 1 条升级为 active

## 硬约束

- 候选不能直接变成 active，必须经此审核流程
- 审核需要 Gate/用户确认
- 去重优先于新增
- 新规则通过 supersedes 指向被替代的旧规则

## 输出格式

```markdown
## 记忆审核报告
- 审核时间：[时间]
- 候选池总量：[N]/30
- 审核结果：
  - 升级为 active：[N] 条
  - rejected：[N] 条
  - expired：[N] 条
  - 合并：[N] 条
- 升级详情：
  1. [memory_id]: [title] → active，写入 [路径]
- 拒绝详情：
  1. [memory_id]: [title] — 原因：[去重/冲突/证据不足/过期/其他]
- 剩余候选池：[N]/30
```

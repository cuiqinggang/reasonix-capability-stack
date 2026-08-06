# /memory recall — 记忆检索

> 轻量入口：仅路由说明，完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 用途

在任务开始时检索相关记忆，辅助决策但不替代当前指令。

## 检索流程

1. 读取 `C:\Users\A\.codex\knowledge-brain\reasonix\CORE_MEMORY.md`（核心摘要）
2. 读取 `.reasonix\registry\reasonix-memory-routing.md`（路由说明）
3. 按任务类别定位相关记忆
4. 最多取 3–5 条 status=active 的记忆
5. 检查每条记忆的：状态、时效、scope、是否被 superseded
6. 输出检索报告：
   - 使用了哪些记忆
   - 为什么相关
   - 来自哪个路径
   - 置信度和最后审核时间

## 硬约束

- 不得整库加载
- 不得把原始聊天记录注入上下文
- 记忆只是辅助，当前真实环境和用户最新指令优先
- 被 superseded 的规则不参与默认检索
- 过期的候选不参与检索

## 输出格式

```markdown
## 记忆检索报告
- 任务类别：[类别]
- 检索范围：10_STABLE_MEMORY/reasonix/
- 命中条数：[N]
- 记忆清单：
  1. [memory_id] [title] — 相关原因 — 置信度：[high/medium/low]
  2. ...
- 未命中原因：[如适用]
```

# /memory health — 记忆健康检查

> 轻量入口：仅路由说明，完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 用途

定期检查记忆系统的健康状态：容量、一致性、过期、孤岛、违规。

## 检查项目

### 1. 容量检查
- 核心摘要字符数 ≤ 1,200
- 候选池条目数 ≤ 30
- 稳定记忆总量（无硬上限，但需报告）

### 2. 一致性检查
- 所有记忆字段完整（16 个必填字段）
- 所有 status 值在六种允许状态内
- 所有 type 值在八种允许类型内
- supersedes 指向的记忆存在且状态为 superseded
- 无同义重复的 active 记忆

### 3. 时效检查
- 候选记忆未超过 30 天未审核
- active 记忆未超过 180 天未检索
- expires_at 已过的条目已处理

### 4. 孤岛检查
- 没有被 superseded 但未标记的旧规则
- 没有 orphan evidence_path

### 5. 违规检查
- 无敏感信息（Key/Token/.env/Hermes）
- 无原始聊天记录
- Knowledge Brain 与 .reasonix 中无大规模重复正文
- 子智能体未直接写入稳定记忆

## 输出格式

```markdown
## 记忆健康检查报告
- 检查时间：[时间]

### 容量
- 核心摘要：[N] 字符 / 1,200 上限 — [OK/OVER]
- 候选池：[N]/30 — [OK/OVER]
- 稳定记忆总数：[N]

### 一致性
- 字段完整率：[N]/[Total] — [OK/ISSUES]
- 非法状态：[N] 条 — [NONE/详单]
- 非法类型：[N] 条 — [NONE/详单]
- 同义重复：[N] 对 — [NONE/详单]

### 时效
- 过期候选：[N] 条 — [NONE/详单]
- 长期未检索 active：[N] 条 — [NONE/详单]

### 孤岛
- 悬空 supersedes：[N] 条 — [NONE/详单]

### 违规
- 敏感信息：[NONE/FOUND]
- 原始聊天：[NONE/FOUND]
- 正文重复：[NONE/FOUND]

### 总体状态
- [HEALTHY / NEEDS_ATTENTION / CRITICAL]
```

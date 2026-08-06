# Reasonix Memory Routing

> 轻量路由说明：Reasonix 如何定位和访问 Knowledge Brain 中的记忆。完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 一、知识大脑路径

```
C:\Users\A\.codex\knowledge-brain\
├── incoming\reasonix-memory-candidates\   ← 候选记忆池（只读检索不从此取）
├── reasonix\             ← 稳定记忆（检索主目标）
├── reasonix\projects\            ← 项目记忆（按项目检索）
└── reasonix\archive\            ← 归档（默认不检索）
```

---

## 二、检索路由

### 启动时（每次任务开始）
1. 读取 `C:\Users\A\.codex\knowledge-brain\reasonix\CORE_MEMORY.md`
2. 读取本路由文件
3. 按任务类别定位相关 active 记忆

### 按类型路由

| 任务类型 | 检索范围 | 优先 type |
|---------|---------|----------|
| 安全相关 | 10_STABLE_MEMORY | hard_rule, system_constraint |
| 用户交互 | 10_STABLE_MEMORY | user_preference |
| 编码任务 | 10_STABLE_MEMORY + 20_PROJECT_MEMORY | validated_lesson, project_decision |
| 流程改进 | 10_STABLE_MEMORY | workflow_candidate, validated_lesson |
| 错误处理 | 10_STABLE_MEMORY | failure_lesson, validated_lesson |
| 项目级决策 | 20_PROJECT_MEMORY | project_decision |

### 检索优先级
1. scope 匹配当前上下文
2. status=active
3. confidence ≥ medium
4. 未过期（expires_at > now 或 N/A）
5. 未被 superseded
6. importance 降序
7. last_reviewed_at 降序

---

## 三、命令入口

| 命令 | 路径 | 用途 |
|------|------|------|
| `/memory recall` | `.reasonix\commands\memory\recall.md` | 检索相关记忆 |
| `/memory capture` | `.reasonix\commands\memory\capture.md` | 真实任务后提取候选记忆 |
| `/memory dedupe` | `.reasonix\commands\memory\dedupe.md` | 候选去重检查 |
| `/memory conflict` | `.reasonix\commands\memory\conflict.md` | 三向冲突检查 |
| `/memory evidence` | `.reasonix\commands\memory\evidence.md` | 证据链验证 |
| `/memory gate` | `.reasonix\commands\memory\gate.md` | Gate 审查汇总 |
| `/memory activate` | `.reasonix\commands\memory\activate.md` | 安全激活（仅主执行者） |
| `/memory trial-status` | `.reasonix\commands\memory\trial-status.md` | 试运行状态仪表盘 |
| `/memory propose` | `.reasonix\commands\memory\propose.md` | 提交候选记忆（旧入口） |
| `/memory review` | `.reasonix\commands\memory\review.md` | 审核候选记忆（旧入口） |
| `/memory health` | `.reasonix\commands\memory\health.md` | 健康检查 |

---

## 四、写入路由

### 谁可以写哪里

| 角色 | 00_INBOX | 10_STABLE | 20_PROJECT | 30_ARCHIVE |
|------|----------|-----------|------------|------------|
| 主执行者 | ✅ propose | ✅ 经审核后 | ✅ | ✅ 归档 |
| 子智能体 | ✅ 提交候选 | ❌ 禁止 | ❌ 禁止 | ❌ 禁止 |
| 用户 | ✅ | ✅ | ✅ | ✅ |

---

## 五、与 Knowledge Brain 的关系

- Reasonix 记忆治理文件存储在 `reasonix/` 子目录下，与 Knowledge Brain 其他资料共存于 `C:\Users\A\.codex\knowledge-brain`
- 候选记忆存储于 `incoming\reasonix-memory-candidates\`
- Knowledge Brain 原有的 INDEX.md、ROUTING_MAP.md、MANIFEST.json 管理 413+ 条目的路由，不受影响
- Reasonix 记忆治理在此库中作为一个独立分区（`reasonix/`）运行
- 任务执行时通过本路由定位 Reasonix 记忆，必要时可查阅 Knowledge Brain 其他索引
- `C:\AI\knowledge-brain` 已退役为 INERT_UNREFERENCED_SCAFFOLD，不再被 Reasonix 活跃引用

---

## 六、路径速查

| 内容 | 路径 |
|------|------|
| 核心摘要 | `C:\Users\A\.codex\knowledge-brain\reasonix\CORE_MEMORY.md` |
| 治理规则 | `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md` |
| 候选模板 | `C:\Users\A\.codex\knowledge-brain\incoming\reasonix-memory-candidates\MEMORY_CANDIDATE_TEMPLATE.md` |
| 项目模板 | `C:\Users\A\.codex\knowledge-brain\reasonix\projects\PROJECT_MEMORY_TEMPLATE.md` |
| 归档策略 | `C:\Users\A\.codex\knowledge-brain\reasonix\archive\MEMORY_ARCHIVE_POLICY.md` |
| 本路由 | `.reasonix\registry\reasonix-memory-routing.md` |
| recall | `.reasonix\commands\memory\recall.md` |
| capture | `.reasonix\commands\memory\capture.md` |
| dedupe | `.reasonix\commands\memory\dedupe.md` |
| conflict | `.reasonix\commands\memory\conflict.md` |
| evidence | `.reasonix\commands\memory\evidence.md` |
| gate | `.reasonix\commands\memory\gate.md` |
| activate | `.reasonix\commands\memory\activate.md` |
| trial-status | `.reasonix\commands\memory\trial-status.md` |
| propose | `.reasonix\commands\memory\propose.md` |
| review | `.reasonix\commands\memory\review.md` |
| health | `.reasonix\commands\memory\health.md` |

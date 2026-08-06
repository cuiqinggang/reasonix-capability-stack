# /memory conflict — 记忆冲突检查

> 轻量入口：完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md` 和 `reasonix\CORE_MEMORY.md`

---

## 用途

三向冲突检查：vs active 记忆、vs 用户最新指令、vs CORE_MEMORY 硬规则。

## 输入

- `target_memory_id`：待检查的记忆 ID
- 可选 `context`：当前 task_id 和用户最新指令片段

## 三个冲突维度

### 维度 A：与 active 记忆冲突

| 类型 | 条件 |
|------|------|
| 矛盾 | 同一 scope 下对同一事物给出互斥结论 |
| 互斥 | 两条记忆不能同时成立 |
| 范围重叠但结论相反 | scope 有交集，结论矛盾 |
| 同义但参数冲突 | 本质同一件事，参数/偏好不同 |

### 维度 B：与用户最新指令冲突

| 类型 | 条件 |
|------|------|
| 直接否定 | 用户最近说了与候选相反的明确指令 |
| 范围越权 | 候选 scope 覆盖用户明确保留的自主决策领域 |
| 时效优先 | 用户最新指令与旧记忆矛盾 → 用户最新指令胜出 |

### 维度 C：与 CORE_MEMORY 硬规则冲突

对照 `reasonix\CORE_MEMORY.md` 逐项硬规则：
- 安全边界（Hermes/密钥/Token）
- 治理硬规则（摘要上限/检索上限/Gate 审核）
- 固定执行规则（主执行者唯一写入/子智能体只读）
- 容量规则（3 条候选/30 条池/1 条 stable）

**C 维度硬违规 → 直接 REJECT，无 DEFER 路径**

## supersedes 正确性检查

若候选声明 `supersedes`：
- [ ] 被指向 memory_id 存在
- [ ] 被指向记忆 status = active
- [ ] scope 覆盖或等于
- [ ] type 同一大类
- [ ] 替代说明明确且非简单复制
- [ ] retrieval_hint 标注替代关系

## 综合判定

| 结果 | 条件 |
|------|------|
| **PASS** | 三维度均无冲突 |
| **SUPERSEDE** | A 有冲突但 supersedes 正确设置 |
| **REJECT** | C 硬违规 / A 矛盾无法通过 supersedes 解决 |
| **DEFER** | A/B 有冲突需用户确认 / supersedes 不完整 |

## 输出格式

```markdown
## 冲突检查报告
- 目标：[memory_id] [title] | 时间：[时间]

### 维度 A：vs active 记忆
- 检查数：[N] | 冲突数：[N]
- 冲突：vs [active_id] [title] — [矛盾/互斥/范围重叠/同义参数冲突]
  - supersedes 声明：[是/否] | 替代合理性：[合理/不合理]

### 维度 B：vs 用户最新指令
- 冲突数：[N] | 无冲突：[✓]

### 维度 C：vs CORE_MEMORY
- 硬安全边界：[PASS/VIOLATION] | 治理硬规则：[PASS/VIOLATION]

### supersedes 检查（如适用）
- 指向存在：[是/否] | 状态正确：[是/否] | scope 覆盖：[是/否]

### 总体判定：[PASS / SUPERSEDE / REJECT / DEFER]
```

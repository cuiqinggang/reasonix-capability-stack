# /memory evidence — 记忆证据检查

> 轻量入口：完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 用途

验证候选记忆的证据链完整性：任务 ID 真实、证据路径存在、来源明确、有未来执行价值。

## 输入

- `target_memory_id`：待检查的记忆 ID

## 四项检查

### 1. 任务 ID 真实性

| 子项 | PASS 条件 | REJECT/DEFER 条件 |
|------|-----------|-------------------|
| 1a | source 包含可识别 task_id | MISSING → REJECT |
| 1b | 任务产物在 reports/evidence 有迹可查 | UNTRACEABLE → DEFER |
| 1c | 非占位符 (task-000000/test-task/N/A) | PLACEHOLDER → REJECT |

### 2. 证据路径可验证性

| 子项 | PASS 条件 | REJECT/DEFER 条件 |
|------|-----------|-------------------|
| 2a | evidence_path 非空且 ≠ N/A | EMPTY → REJECT |
| 2b | 指向文件实际存在 | NOT_FOUND → DEFER |
| 2c | 文件 ≥ 50 bytes | EMPTY/CORRUPT → REJECT |
| 2d | 内容与 candidate 直接关联 | IRRELEVANT → DEFER |
| 2e | 路径不指向 knowledge-brain 外部 | EXTERNAL → REJECT |

**2a FAIL → 直接 REJECT（不符合准入条件 #3）**

### 3. 来源明确性

| 子项 | PASS 条件 | REJECT/DEFER 条件 |
|------|-----------|-------------------|
| 3a | source 明确标注类型（用户指令/验收报告/测试结果） | VAGUE → DEFER |
| 3b | 可追溯到具体实体 | AMBIGUOUS → DEFER |
| 3c | 非模型猜测 | MODEL_GUESS → REJECT |
| 3d | 用户指令来源有会话痕迹（可选） | UNVERIFIABLE → DEFER |

### 4. 未来执行价值

| 子项 | PASS 条件 | REJECT/DEFER 条件 |
|------|-----------|-------------------|
| 4a | retrieval_hint 非空且非占位符 | MISSING → DEFER |
| 4b | 明确描述"何时应检索此记忆" | TOO_VAGUE → DEFER |
| 4c | content 可用作决策/执行依据 | PURELY_DESCRIPTIVE → REJECT |
| 4d | 满足准入条件 #4（长期价值） | ONE_OFF → REJECT |

## 综合判定

| 结果 | 条件 |
|------|------|
| **PASS** | 四项全部 PASS |
| **DEFER** | 1–2 个 DEFER，无 REJECT |
| **REJECT** | 任一项 REJECT |

## 输出格式

```markdown
## 证据检查报告
- 目标：[memory_id] [title] | 时间：[时间]

### 逐项结果
| 检查项 | 判定 | 详情 |
|--------|------|------|
| 1. 任务 ID | [PASS/DEFER/REJECT] | [详情] |
| 2. 证据路径 | [PASS/DEFER/REJECT] | [详情] |
| 3. 来源明确性 | [PASS/DEFER/REJECT] | [详情] |
| 4. 未来价值 | [PASS/DEFER/REJECT] | [详情] |

### 综合判定：[PASS / DEFER / REJECT]
- 缺陷清单：[如有]
- 建议操作：[可直接升级 / 补齐证据 / 拒绝]
```

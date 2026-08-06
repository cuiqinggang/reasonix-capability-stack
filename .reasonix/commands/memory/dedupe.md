# /memory dedupe — 候选记忆去重

> 轻量入口：完整治理规则见 `C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`

---

## 用途

检查候选记忆是否与已有 active 记忆或候选池中其他候选重复。

## 检查对象

| 源 | 路径 |
|----|------|
| 待检查候选 | `incoming\reasonix-memory-candidates\CAND-*.md` |
| Active 记忆 | `reasonix\*.md`（排除 superseded/archived） |
| 已有候选 | `incoming\reasonix-memory-candidates\`（排除自身和 expired） |

## 四个比对维度

| 维度 | 权重 | 方法 |
|------|------|------|
| 标题相似度 | 30% | 关键词 Jaccard ≥ 0.7 为可疑 |
| content 语义等价 | 40% | 是否表达同一规则/偏好/决策 |
| scope 重叠 | 15% | 适用范围是否相交 |
| type 一致性 | 15% | 类型是否相同 |

## 重复判定标准

| 等级 | 条件 | 判定 | 建议 |
|------|------|------|------|
| **EXACT_MATCH** | 标题相似度 ≥ 0.9 且语义等价 | REJECT | 标注重复的 active memory_id |
| **SYNONYM** | 标题相似度 0.5–0.9 且语义等价 | REJECT | 若新表述更清晰可考虑 supersede |
| **SUPERSET** | 新包含旧全部信息 + 额外信息 | PASS | 建议新 supersede 旧 |
| **SUBSET** | 新是旧的子集 | REJECT | 建议合并到已有记忆 |
| **CONFLICT** | scope 重叠且内容矛盾 | HOLD | 需用户手动裁决 |
| **NO_MATCH** | 无显著重叠 | PASS | 安全保留 |

## 特殊规则

- `user_preference` 与 `hard_rule` 不互比（跨类型豁免）
- 同一 task ID 的多条候选间不做去重拒绝（标注关联即可）
- superseded/expired 不参与比对

## 输出格式

```markdown
## /memory:dedupe 去重报告
- 检查时间：[时间] | 待检查：[N] 条 | Active 池：[M] 条 | 候选池：[K] 条

### CAND-YYYYMMDD-NNN：[title]
| 对比方 | memory_id | 标题 | 相似度 | 判定 | 建议 |
|--------|-----------|------|--------|------|------|
| active | MEM-xxx | ... | 0.92 | EXACT_MATCH | REJECT |
| candidate | CAND-zzz | ... | 0.15 | NO_MATCH | — |
- 最终判定：[PASS / REJECT / HOLD]

### 汇总
| 候选 | 判定 | 冲突方 | 操作 |
|------|------|--------|------|
| CAND-... | PASS | — | 保留 |
| CAND-... | REJECT | MEM-xxx | 拒绝（完全重复） |

- 通过：[P] | 拒绝：[R] | 待裁决：[H]
```

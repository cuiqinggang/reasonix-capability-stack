# 第一期长期记忆架构冲突只读验收报告

> 报告时间：2026-08-06 | 文件名：phase-1-memory-root-conflict-audit-20260806-0535.md

---

## 结论：C — CUTOVER_DECISION_REQUIRED

原有成熟知识大脑与第一期新建空结构并存；必须由用户决定未来唯一权威根目录。

---

## 两个路径的真实资料情况

### 路径 1：`C:\Users\A\.codex\knowledge-brain`（成熟库）

| 维度 | 数据 |
|------|------|
| 存在性 | ✅ 存在，历史积累 |
| 总文件数 | ~420 文件 |
| 四层结构 | ❌ 无（采用自有扁平+功能分区结构） |
| INDEX.md | ✅ 3,497 B，v1.3-c-hotpath |
| ROUTING_MAP.md | ✅ 7,852 B，双引擎路由（ECC + Loop） |
| MANIFEST.json | ✅ 1.18 MB，1,917 索引文件，11 数据源 |
| 同步体系 | Hot Sync / Light Sync / Deep Sync 三级 |
| 最新活动 | 2026-08-05 20:12（Hot Sync），本轮之前 |
| reasonix 关联 | ❌ 无 reasonix 子目录或文件 |
| 本轮改动 | ❌ 无任何文件被本轮修改（全部修改时间 ≤ 2026-08-05） |
| 结构特点 | `incoming/`（替代 00_INBOX）、`indexes/`、`scripts/`、`tools/`、`sources/`、`agent-prompts/`、`logs/`（~360 条） |

### 路径 2：`C:\AI\knowledge-brain`（新建框架）

| 维度 | 数据 |
|------|------|
| 存在性 | ✅ 存在，本期新建 |
| 总文件数 | 9 个 .md 文件 |
| 四层结构 | ✅ 完整（00_INBOX / 10_STABLE / 20_PROJECT / 30_ARCHIVE） |
| INDEX.md | ❌ 缺失 |
| ROUTING_MAP.md | ❌ 缺失 |
| MANIFEST.json | ❌ 缺失 |
| 真实记忆内容 | ❌ 无 — 全为模板、规则、测试夹具 |
| 创建时间 | 2026-08-06 05:25–05:28（3 分钟窗口） |
| 总大小 | ~14 KB |
| 旧路径引用 | 零 — 完全自包含 |

---

## 当前 Reasonix 实际读取路径

### Memory 命令体系（本期新建）→ 全部指向 `C:\AI\knowledge-brain`

| 入口 | 实际读取目标 |
|------|------------|
| `/memory recall` | `C:\AI\knowledge-brain\10_STABLE_MEMORY\reasonix\CORE_MEMORY.md` |
| `/memory propose` | `C:\AI\knowledge-brain\00_INBOX\reasonix-memory-candidates\` |
| `/memory review` | `C:\AI\knowledge-brain\00_INBOX\reasonix-memory-candidates\` |
| `/memory health` | `C:\AI\knowledge-brain\10_STABLE_MEMORY\reasonix\MEMORY_GOVERNANCE.md` |
| `reasonix-memory-routing.md` | 路由表指向 `C:\AI\knowledge-brain`（主）+ 声明旧库为"外部权威" |

### reasonix-knowledge 技能（既有）→ 桥接到 `C:\Users\A\.codex\knowledge-brain`

| 入口 | 实际读取目标 |
|------|------------|
| `reasonix-knowledge` SKILL.md | `C:\Users\A\.codex\knowledge-brain\INDEX.md` + ROUTING_MAP.md + tools/ |

### 交叉引用情况

`reasonix-memory-routing.md` 第 73–75 行明确声明了双轨并存：

> "reasonix-knowledge 技能桥接到 C:\Users\A\.codex\knowledge-brain（外部权威知识库，413+ 条目）"
> "本路由系统管理 C:\AI\knowledge-brain（Reasonix 原生记忆库）"
> "两者路径不同，不冲突"

---

## 是否已经形成平行知识库

**是，已形成事实上的平行结构：**

1. `C:\AI\knowledge-brain` — Reasonix 记忆治理框架（空壳，无真实记忆），被 `/memory *` 命令体系引用
2. `C:\Users\A\.codex\knowledge-brain` — 成熟的 AI Company OS 知识大脑（~420 文件，1,917 索引条目），被 `reasonix-knowledge` 技能引用

**但两库当前的分工有逻辑自洽性：**
- 新库负责 Reasonix 的原生记忆治理（candidate → active 流程）
- 旧库负责外部知识检索（INDEX → ROUTING_MAP → 分类索引）

**风险点：**
- 新库没有 INDEX.md / ROUTING_MAP.md，无法独立运作
- 旧库没有四层结构，无法直接套用新治理规则
- 如果未来真实记忆需要落地，会面临"写哪个库"的决策冲突

---

## 是否允许继续第二期

**NO** — 必须先解决根目录冲突。

在用户做出以下决策之前，第二期（候选记忆审核自动化、Gate Review 流程等）不应继续：

| 选项 | 行动 |
|------|------|
| **保留旧库** | 将第一期治理文件迁移到 `C:\Users\A\.codex\knowledge-brain` 的对应位置，废弃 `C:\AI\knowledge-brain`，更新所有 memory 命令路径 |
| **切换到新库** | 制定独立迁移计划，将旧库的 INDEX/ROUTING_MAP/资料逐步迁移到 `C:\AI\knowledge-brain` 四层结构，更新 reasonix-knowledge 技能 |
| **保持双轨** | 明确两个库的职责边界和互操作规则，补齐新库的 INDEX.md 和 ROUTING_MAP.md |

---

## 附：检查清单

| 检查项 | 结果 |
|--------|------|
| 旧库存在 | ✅ |
| 新库存在 | ✅ |
| 旧库有四层结构 | ❌（自有扁平结构） |
| 新库有四层结构 | ✅ |
| 旧库有 INDEX.md | ✅ |
| 新库有 INDEX.md | ❌ |
| 旧库有 ROUTING_MAP.md | ✅ |
| 新库有 ROUTING_MAP.md | ❌ |
| 旧库被本轮改动 | ❌（未触碰） |
| Reasonix memory 命令 → 新库 | ✅ |
| reasonix-knowledge → 旧库 | ✅ |
| 交叉读取两个目录 | ⚠️ routing.md 声明双轨，但未实跑交叉读取 |
| 本轮新建文件在哪个根 | 全部在 `C:\AI\knowledge-brain` |
| Hermes 被读取 | ❌ |
| .env/Key 被读取 | ❌ |
| 任何文件被修改 | ❌（仅写入本报告） |

---

> END OF AUDIT REPORT

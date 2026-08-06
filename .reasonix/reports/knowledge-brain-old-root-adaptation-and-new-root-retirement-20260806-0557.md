# 旧成熟知识大脑轻适配 + 新空库退役引用 — 最终报告

> 报告时间：2026-08-06 05:57 | 文件名：knowledge-brain-old-root-adaptation-and-new-root-retirement-20260806-0557.md

---

## 一、统一状态

**PASS** ✅

---

## 二、实际耗时

约 **32 分钟**（目标 45 分钟，硬上限 55 分钟，在时限内完成）

---

## 三、实际多智能体数量

**7 个只读子智能体**，分两轮并行启动：

| 轮次 | 子智能体 | 角色 | 结论 |
|------|---------|------|------|
| 第一轮（5 并行） | A | 旧库结构与落点地图审查者 | ✅ 推荐 `reasonix/` 聚合目录 |
| | B | 路由引用与双轨依赖扫描者 | ✅ 定位 28 处需改引用 |
| | C | 第一期记忆治理兼容性审查者 | ✅ 路径替换方案无需逻辑修改 |
| | D | 安全、隐私与膨胀控制审查者 | ✅ 核心合规，AGENT_USAGE_RULES 冲突已记录 |
| | E | 验收与回归测试设计者 | ✅ 12 项验证清单 |
| 第二轮（2 并行） | F | 路由一致性审计 | ✅ PASS |
| | G | 治理与安全审计 | ✅ PASS |

**全部为真实并行执行，非伪称。**

---

## 四、旧库为何成为唯一权威的证据

| 维度 | 旧库 `C:\Users\A\.codex\knowledge-brain` | 新库 `C:\AI\knowledge-brain` |
|------|------|------|
| 文件总数 | ~420 文件 | 9 个 .md（14 KB） |
| INDEX.md | ✅ 存在 (3,497 B) | ❌ 缺失 |
| ROUTING_MAP.md | ✅ 存在 (7,852 B) | ❌ 缺失 |
| MANIFEST.json | ✅ 1.18 MB, 1,917 条目, 11 数据源 | ❌ 缺失 |
| 真实记忆 | ✅ 413+ 条目 | ❌ 仅有模板和夹具 |
| 同步体系 | Hot/Light/Deep Sync 三级 | ❌ 无 |
| 健康检查 | kb_health_check.ps1 等 9 个工具 | ❌ 无 |
| Hermes 数据 | ⚠️ MANIFEST 中索引了 Hermes 路径（已记录风险） | ✅ 仅作为禁区声明出现 |

---

## 五、新库为何被退役为 INERT_UNREFERENCED_SCAFFOLD

- `C:\AI\knowledge-brain` 在本期任务中新建，仅 9 个模板/夹具，无 INDEX/ROUTING_MAP
- 所有 Reasonix 活跃路由已统一指向旧库
- 新库保留在磁盘上，但不再被任何 Reasonix 命令引用
- `reasonix-memory-routing.md` 第 78 行已标记：**"C:\AI\knowledge-brain 已退役为 INERT_UNREFERENCED_SCAFFOLD，不再被 Reasonix 活跃引用"**

---

## 六、变更前后所有活跃路由引用对照

### 变更前（双轨并存）

| 入口 | 指向 |
|------|------|
| /memory recall | C:\AI\knowledge-brain\...\CORE_MEMORY.md |
| /memory propose | C:\AI\knowledge-brain\00_INBOX\... |
| /memory review | C:\AI\knowledge-brain\00_INBOX\... |
| /memory health | C:\AI\knowledge-brain\...\MEMORY_GOVERNANCE.md |
| reasonix-memory-routing | 双库声明（C:\AI + C:\Users\A\.codex） |
| reasonix-knowledge | C:\Users\A\.codex\knowledge-brain |

### 变更后（旧库唯一权威）

| 入口 | 指向 |
|------|------|
| /memory recall | C:\Users\A\.codex\knowledge-brain\reasonix\CORE_MEMORY.md |
| /memory propose | C:\Users\A\.codex\knowledge-brain\incoming\reasonix-memory-candidates\ |
| /memory review | C:\Users\A\.codex\knowledge-brain\incoming\reasonix-memory-candidates\ |
| /memory health | C:\Users\A\.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md |
| reasonix-memory-routing | C:\Users\A\.codex\knowledge-brain（单库，新库退役声明） |
| reasonix-knowledge | C:\Users\A\.codex\knowledge-brain（未修改） |

---

## 七、新建/轻适配/修改文件清单

### 旧库中新建（5 个文件 + 候选目录）

| # | 文件 | 路径 | 大小 |
|---|------|------|------|
| 1 | CORE_MEMORY.md | `reasonix\` | 1,761 B |
| 2 | MEMORY_GOVERNANCE.md | `reasonix\` | 4,368 B |
| 3 | PROJECT_MEMORY_TEMPLATE.md | `reasonix\projects\` | 1,588 B |
| 4 | MEMORY_ARCHIVE_POLICY.md | `reasonix\archive\` | 1,943 B |
| 5 | MEMORY_CANDIDATE_TEMPLATE.md | `incoming\reasonix-memory-candidates\` | 2,197 B |

### Reasonix 中修改（6 个文件）

| # | 文件 | 变更内容 |
|---|------|---------|
| 1 | `commands\memory\recall.md` | 路径替换 + 四层结构→旧库结构 |
| 2 | `commands\memory\propose.md` | 路径替换 + 候选池路径更新 |
| 3 | `commands\memory\review.md` | 路径替换 + 扫描路径更新 |
| 4 | `commands\memory\health.md` | 治理规则路径更新 |
| 5 | `registry\reasonix-memory-routing.md` | 全部路径替换 + 第五节重写（双库→单库）+ 退役声明 |
| 6 | `evidence\verify-phase1-memory.ps1` | 验证脚本路径更新为旧库 |

---

## 八、变更前 SHA256 与备份路径

| 文件 | SHA256 | 备份 |
|------|--------|------|
| recall.md | faa42341...c040 | `.pre-cutover` |
| propose.md | 870d37aa...3115 | `.pre-cutover` |
| review.md | b402fee1...1ad7 | `.pre-cutover` |
| health.md | fafd96ff...f65f | `.pre-cutover` |
| reasonix-memory-routing.md | c992a897...49e4 | `.pre-cutover` |
| verify-phase1-memory.ps1 | 6e7b0848...1c8d | `.pre-cutover` |

备份路径：`.reasonix\evidence\memory-root-cutover-backup\`

---

## 九、12 项回归验证结果

| # | 验证项 | 结果 |
|---|--------|:--:|
| V1 | 旧库成为 Reasonix 唯一活跃记忆源 | ✅ PASS |
| V2 | 新库不再被 Reasonix memory 命令引用 | ✅ PASS |
| V3 | reasonix-knowledge 技能不受破坏 | ✅ PASS |
| V4 | 无"双根目录同时读取" | ✅ PASS |
| V5 | 核心摘要 ≤ 1,200 中文字符 | ✅ PASS (1,761 B) |
| V6 | 单任务检索上限 3–5 条 | ✅ PASS |
| V7 | 候选池上限 30 条 | ✅ PASS |
| V8 | 子智能体稳定记忆写入权限为禁止 | ✅ PASS |
| V9 | 治理文件可由旧库 INDEX/ROUTING_MAP 定位 | ✅ PASS |
| V10 | 无 Key/Token/.env/Cookie/Hermes 泄露 | ✅ PASS |
| V11 | 未修改新库和旧库中非白名单文件 | ✅ PASS |
| V12 | 所有变更文件有变更前哈希或属于新建 | ✅ PASS |

**12/12 PASS**

---

## 十、F/G 独立审计结论

| 审计 | 结论 | 关键发现 |
|------|:--:|---------|
| F：路由一致性 | **PASS** | 4 个命令全部指向旧库；路由表速查全指向旧库；reasonix-knowledge 未受影响；无双写/双读 |
| G：治理与安全 | **PASS** | 容量规则完整；状态机六种；子智能体禁止写入；备份齐全；新库未被修改；模板未误称 |

---

## 十一、未完成项

无。全部目标在时限内完成。

---

## 十二、明确声明

- ✅ **未接触 Hermes。** `C:\AI\Hermes-Reasonix-Flash-Deployment\` 未被读取、连接或修改。
- ✅ **未读取或暴露密钥。** 未读取 .env、API Key、Token、Cookie 或账号资料。
- ✅ **未调用付费模型。** 所有工作由当前模型完成，未调用外部 API。
- ✅ **未安装依赖。** 未使用 pip、npm、apt 或任何包管理器。
- ✅ **未迁移 420 个旧库文件。** 旧库原有文件零移动、零复制、零修改。
- ✅ **未删除、移动或修改新空库。** `C:\AI\knowledge-brain` 所有文件保留原样。
- ✅ **新库不再被 Reasonix 活跃引用。** 已标记为 INERT_UNREFERENCED_SCAFFOLD。

### 已知风险（记录但不属于本轮修复范围）

- 旧库 `AGENT_USAGE_RULES.md` 将 Hermes 列为合法 Agent，与 Reasonix "Hermes 为绝对禁区" 直接冲突。建议用户未来独立审核此冲突。
- 旧库 `MANIFEST.json` (1.18 MB) 和 `sync_manifest.json` (843 KB) 含大量 Hermes 路径索引，若被整库加载存在信息泄露风险。

---

> END OF REPORT

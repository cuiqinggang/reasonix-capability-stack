---
name: reasonix-recovery-kit
description: Reasonix 专属能力恢复技能包：完整记录 13 技能/21 命令/7 规则/9 脚本/双知识库/记忆治理/多智能体/外部依赖与安全边界，电脑损坏或环境重建时一次性恢复全部能力。触发词：恢复能力、重建环境、技能包、capability restore、recovery、能力备份。
---

# Reasonix 专属能力恢复技能包（Recovery Kit）

> **建立时间**：2026-08-05 夜（跨 2026-08-06 凌晨持续演进）
> **能力状态**：100%（评分轨迹 77.5 → 86.3 → 86.9 → 92.0 → 100，verify-runtime v2.0 ALL_PASS 46/46，full-verify 5/5 子系统）
> **用途**：电脑损坏、环境重建、新会话接手时，按本技能包一次性恢复全部已建成能力。
> **维护**：每完成一次新的能力升级，必须回写本技能包并更新知识库登记（见第十四节）。

---

## 一、核心身份与定位

- Reasonix 是 AI 编码超级工具运行实例，运行于全局工作区 `C:\Users\A\AppData\Roaming\reasonix\global-workspace`。
- 生态站根目录：`<workspace>\.reasonix\`（含 ENTRY.md 轻入口 + 12 个子目录）。
- **唯一权威知识大脑（新）**：`C:\AI\knowledge-brain`（四层结构，2026-08-05 建立，Reasonix 记忆治理底座）。
- **成熟知识库（旧、内容最丰富）**：`C:\Users\A\.codex\knowledge-brain`（413+ 知识条目 / 155 技能索引 / 498 Obsidian 文档 / 2322 项目文档，含 `reasonix/` 稳定记忆区）。
- Reasonix 是知识大脑的「轻量读取者、受控候选写入者、任务执行者」，不是第二知识库。

---

## 二、能力全景（16 项能力矩阵 CAP-01…CAP-16）

| 能力簇 | 状态 |
|--------|------|
| 规则体系落盘 | CORE_PASS |
| verify-runtime 运行时验证 | PASS（46/46） |
| 多智能体（fleet 并行） | PASS_FLEET_REAL |
| 视觉审查（图片） | PASS_REAL_CALL（qwen3-vl-235b 真实调用） |
| 视觉（视频 URL / 本地 MP4） | PASS / PASS_FRAME_FALLBACK |
| checkpoint→handoff→resume 跨会话 | PASS_REAL_CROSS_SESSION |
| 其余能力 | PASS |
| 已弃用 | GLM-4.6v 视觉（DEPRECATED_REMOVED，统一走 qwen3-vl-235b） |

13 个技能：9 个 inline（continuity / ecc-orchestration / evidence-repair / executor-repair / gate-controller / knowledge / loop / mature-core / model-router），4 个 subagent（research / review-audit / test-verify / vision-review）。

---

## 三、核心路径地图（重建时必须逐项确认存在）

```
C:\Users\A\AppData\Roaming\reasonix\global-workspace\.reasonix\
├── ENTRY.md                       轻入口（新会话启动先读）
├── commands\                      21 个命令协议：10 根级 + memory\ 11 个
├── rules\                         7 条规则：core / coding / context-fallback / long-task / review / security / testing
├── registry\                      CAPABILITY_MATRIX.json/.md、skills-index.json、SKILLS_INDEX.md、reasonix-memory-routing.md、tool-registry.json
├── skills\                        13 个技能目录（各含 SKILL.md；continuity 含 lib/continuity.py + scripts/；model-router 含 rules/ + scripts/）
├── references\                    6 个重资料：ASSET-SEARCH-PATHS / CHECKLISTS / FAILURE-MODES / REPORT-TEMPLATE / SOP / VERIFICATION-LOGIC
├── reports\                       验证报告（gate-review-*、repair-log-*、full-verify.json、runtime-verify.json、阶段 .md）
├── evidence\                      evidence-manifest.json（EVD-001~015）+ maturity-validation\ + 视觉证据
├── state\                         checkpoints\ + handoffs\ + routing-log.jsonl + continuity\tasks\
├── scripts\                       9 个脚本（见第七节）
└── autoresearch\                  LEGACY_EXCLUDED_FROM_CURRENT_ECOSYSTEM（隔离，不参与生态）

C:\AI\knowledge-brain\             权威知识大脑（四层）
├── 00_INBOX\reasonix-memory-candidates\   候选记忆池（上限 30）
├── 10_STABLE_MEMORY\reasonix\             CORE_MEMORY.md + MEMORY_GOVERNANCE.md
├── 20_PROJECT_MEMORY\reasonix\            PROJECT_MEMORY_TEMPLATE.md
└── 30_ARCHIVE\reasonix-memory\            MEMORY_ARCHIVE_POLICY.md

C:\Users\A\.codex\knowledge-brain\        成熟知识库（只读引用，C 盘唯一权威）
├── INDEX.md / ROUTING_MAP.md / HOT_ROUTE_RULES.md
├── indexes\  (skills-index.md 155 技能 / reports-index / commands-index / obsidian-index / code-reference-index)
├── reasonix\ (CORE_MEMORY.md + MEMORY_GOVERNANCE.md + archive\ + projects\)
└── tools\    kb_health_check.ps1 / kb_hot_sync.ps1 / kb_deep_sync.ps1 / kb_audit_all_sources.ps1
```

---

## 四、13 个技能逐一说明

| # | 技能 | runAs | 一句话用途 | 核心机制 | 依赖 |
|---|------|-------|-----------|---------|------|
| 1 | reasonix-continuity | inline | 长任务连续性增强引擎 | 原子写入 os.replace + SHA256 哈希链 + 损坏回退 + 交接/恢复；6 个 Python 脚本 new-task→save-checkpoint→write-handoff→resume→close；状态存 `.reasonix/state/continuity/` | 本地脚本 + lib/continuity.py，无外部 API |
| 2 | reasonix-ecc-orchestration | inline | 四角色十二层闭环 | 控制/资料/工程执行/独立审计四类真实角色跑固定十二层流程；第 9 层必须不同智能体独立验收；≤3 轮返修且每轮换策略 | Reasonix 原生 multi-agent/subagent |
| 3 | reasonix-evidence-repair | inline | 证据闭环修复 | 12 道 Gate：CHANGE_CONTRACT→影响图→SHA-256 冻结→修源头→全量重建→正向必需项→负向禁止项→派生一致性→独立验证器→冷启动→视觉语义→证据矩阵 E0-E4 | CHANGE_CONTRACT.json + 打包工具 |
| 4 | reasonix-executor-repair | subagent | 执行器修复闭环 | 被拒 claim 触发：根因分析→最小修复→回归重验；每项 ≤3 轮，第 4 轮 EXHAUSTED 升级人工；绝不改验收标准迁就证据 | `.reasonix/reports/` + Gate 报告输入 |
| 5 | reasonix-gate-controller | subagent | 关卡控制器（Gate Review） | 9 步：提取 claims→收集证据→双向加权评分（execution_real+3/tool_invoked+2/output_generated+3；mock_detected-4/missing_execution-5/routing_bypass-5）→score≥5 OK、1-4 DEGRADED、≤0 FAIL→总体判定→报告→REJECTED 转 repair-loop | `.reasonix/evidence/` + `.reasonix/reports/` |
| 6 | reasonix-knowledge | inline | 本机知识库只读访问 | 固定 4 步检索：INDEX.md→ROUTING_MAP.md→分类索引→Top-K 权威文档；不默认全量读 Obsidian；C 盘唯一权威（K/H 盘禁止回填） | C:\Users\A\.codex\knowledge-brain + tools\kb_*.ps1 |
| 7 | reasonix-loop | inline | 长期循环工程 | 主循环（读合同→判断→执行/路由→验证→更新状态）；4 类循环 goal/scheduled/event/hybrid；每轮更新 STATE.json + RUN-LOG.jsonl；熔断转 BLOCKED/HUMAN_REQUIRED；定期回顾出 EVOLVE_CANDIDATE | LOOP-CONTRACT.json 等本地文件 |
| 8 | reasonix-mature-core | subagent | 原生最小成熟能力包 v1.0 | 六项通用能力：安全边界/执行验证/Gate Review/Repair Loop/长任务 checkpoint-handoff-resume/三只读子智能体调度；声明分类 active_config_confirmed / live_call_verified 等；长任务阈值 ≥30 步或 ≥5 分钟 | references\ 5 细则 + 3 个子技能 |
| 9 | reasonix-model-router | inline | 自适应模型路由（四级阶梯） | /flash /pro /glm /vision /auto 显式命令 > 媒体强制 qwen3-vl > 复杂度评分分层（0-3 Flash、4-7 Pro、≥8 GLM）；classify-task.ps1 / route-task.ps1 / invoke-router.ps1 / verify-router.ps1 | DEEPSEEK_API_KEY + OPENROUTER_API_KEY（仅环境变量）+ scripts\*.ps1 |
| 10 | reasonix-research | subagent | 资料研究 | 搜索优先级：工作区→全局 skills→知识索引→Web；输出带来源 JSON | web_fetch 唯一网络依赖 |
| 11 | reasonix-review-audit | subagent | 只读代码审查+安全审计 | review/audit/review+audit 三模式；内置扫描（API key、sk- 前缀、OPENROUTER|ANTHROPIC|OPENAI|GEMINI_API_KEY 正则、.env 等敏感路径）；verdict APPROVED/CHANGES_REQUESTED/BLOCKED | 只读工具白名单 |
| 12 | reasonix-test-verify | subagent | 测试验证 | 5 步：确认命令→执行收集→统计→区分新/已知失败（对照 known_failures）→JSON 报告；PASS / PASS_WITH_KNOWN_ISSUES / FAIL / PARTIAL | npm test/pytest/go test 等 |
| 13 | reasonix-vision-review | subagent | 视觉审查 | 模式 A 文件级只读核验（存在性/魔数/引用交叉）；模式 B 真实视觉理解走 qwen/qwen3-vl-235b-a22b-instruct；未配置输出 visual_provider: NOT_CONFIGURED 且禁止伪造调用 | OpenRouter 视觉模型（经真实调用验证，证据在 evidence/qwen-vision-evidence-*.json） |

---

## 五、21 个命令协议

### 根级 10 个（`/命令` 直接调用，输出落 `.reasonix/`）

| 命令 | 用途 | 关键产出 |
|------|------|---------|
| /smart-route | 新任务复杂度分流入口 | `.reasonix/state/routing-log.jsonl` |
| /gate-review | 完成声明前的结构化门禁（双向加权评分） | reports/gate-review-{ts}.md/.json |
| /repair-loop | 对 REJECTED 项最小修复+回归（≤3 轮，第 4 轮 EXHAUSTED） | reports/repair-log-{ts}.json |
| /multi-agent | 拆非重叠子任务并行/流水线派发后合并送审 | reports/multi-agent-{ts}.md + evidence/<agent>-{ts}.json |
| /checkpoint | 长任务阶段保存可恢复状态（读回校验） | state/checkpoints/CHECKPOINT-{stage}-{ts}.json |
| /resume | 从最近/指定 checkpoint 恢复（验证文件存在后从 completed+1 继续） | 恢复摘要 + routing-log 记录 |
| /handoff | 换会话/环境前机器可读交接 | state/handoffs/HANDOFF-{ts}.json + HANDOFF-SUMMARY.md |
| /full-verify | 全栈验证：结构/规则/命令/证据/索引/安全 + 4 冒烟 | reports/FULL_VERIFY_REPORT.md + full-verify-{ts}.json |
| /maturity:preflight | 升级前只读基线快照（交叉验证 A-D + 四分类） | evidence/maturity-validation/preflight-{ts}.json |
| /maturity:postflight | 升级后对比验证+评分（PASS_REAL=10/STRUCTURE_ONLY=6/FAIL=0/PENDING=3） | evidence/maturity-validation/postflight-{ts}.json |

### memory 流水线 11 个（记忆治理，规则外置 `.codex\knowledge-brain\reasonix\MEMORY_GOVERNANCE.md`）

```
propose → capture（≤3 条候选）→ dedupe → conflict → evidence → gate
→ review（人工审核）→ activate（唯一状态变更口，仅主执行者）
并行：trial-status（试运行仪表盘）、health（健康检查）、recall（检索入口）
```

| 命令 | 核心规则 |
|------|---------|
| recall | 最多取 3-5 条 active；不得整库加载；用户最新指令优先 |
| propose | 准入≥2 条满足；每任务≤3 条；候选池≤30；30 天未审核→expired；文件名 CAND-YYYYMMDD-NNN.md |
| capture | 前置：验收证据+池未满+task ID；6 准入至少 2，9 拒绝任一击中即 REJECT |
| dedupe | 四维加权（标题 Jaccard 30%+语义 40%+scope 15%+type 15%）；6 级判定 EXACT/SYNONYM→REJECT、SUPERSET→PASS、SUBSET→REJECT、CONFLICT→HOLD、NO_MATCH→PASS |
| conflict | 三向（active/用户指令/CORE_MEMORY）；CORE_MEMORY 硬违规→直接 REJECT 无 DEFER |
| evidence | 4 项：任务 ID 真实/证据路径可验证（2a 空→REJECT，文件≥50B，不指向外部）/来源明确（模型猜测→REJECT）/未来价值 |
| gate | 四维全 PASS→APPROVE_FOR_USER_REVIEW；任一 FAIL→REJECT；只读不写；同 candidate 每任务仅 Gate 一次 |
| activate | 6 硬前置（Gate=APPROVE、本次任务内、用户明确确认、未激活过、池≤30、状态有效）；每任务≤1 条；子智能体绝对禁止；不得自动/批量激活 |
| review | 批量审核候选池；每任务≤1 条升级 active；去重优先于新增 |
| trial-status | 试运行 3 真实任务；试运行期 active 新增必须为 0；池用量 <20🟢/20-26🟡/27-30🔴 |
| health | 5 类检查（容量/一致性/时效/孤岛/违规）；HEALTHY/NEEDS_ATTENTION/CRITICAL |

**反膨胀关键数字**：每任务候选≤3、active≤1；候选池≤30；候选 30 天未审核→expired；active 180 天未检索→需处理；核心摘要≤1200 字符；记忆 6 态状态机（candidate→active/rejected/expired；active→superseded/archived）；16 必填字段；8 种 type。

---

## 六、7 条规则（rules\）

| 文件 | 核心 |
|------|------|
| core-rules.md | 主路由 + 任务类型→落位映射 + 不可妥协安全边界 |
| coding-rules.md | 文件操作/代码质量/语言（默认简体中文）/验证四类规范；不擅自 commit |
| context-fallback-rules.md | 上下文升级链（收敛→checkpoint→handoff→新会话）；切换需≥2 项依据 |
| long-task-rules.md | 长任务定义（>30 步或 >5 分钟）；每阶段≤10 步写 checkpoint |
| review-rules.md | Gate 双向验证 + 加权评分（execution_real+3 / mock_detected-4；score≥5=OK） |
| security-rules.md | 密钥脱敏（前后各 4 位）、文件系统/网络/系统级禁止清单、审计扫描 |
| testing-rules.md | 10 层测试体系（Smoke/Gate/Repair/Multi-Agent/Checkpoint/Handoff/LongTask/Skills/Security/Recovery） |

---

## 七、9 个脚本（scripts\，PowerShell 7 已验证 7.6.4 兼容）

| 脚本 | 用途 |
|------|------|
| verify-runtime.ps1 | 运行时验证 V2.0：10 类 43-46 项检查，输出 reports/runtime-verify.json，FAIL 退出码 1 |
| full-verify.ps1 | 全量验证总入口：串联 5 子系统（verify-runtime / rebuild-skill-index 交叉验证 / continuity SHA256 链 / routing-log 完整性 / evidence 计数） |
| rebuild-skill-index.ps1 | 扫描 skills/*/SKILL.md frontmatter 重建 SKILLS_INDEX.md + skills-index.json（含交叉验证） |
| collect-evidence.ps1 | 扫描 evidence/checkpoints/handoffs/reports 生成 evidence-manifest.json |
| create-handoff.ps1 | 生成 handoff.json + HANDOFF-SUMMARY.md（读回写回校验 integrity） |
| replay.ps1 | 从 checkpoint/handoff JSON 生成可审计回放摘要 |
| rollback.ps1 | 基于 checkpoint 回退任务状态到指定阶段 |
| video-retry.py | 多模态视频重试：统一 qwen3-vl-235b，指数退避 60/120/240s ≤3 次，走 OpenRouter |
| README.md | 脚本目录文档 |

**注意**：Windows 下 .ps1 需 UTF-8 with BOM 才能被 PowerShell 正确解析（踩过的坑：rebuild-skill-index.ps1 与 CAPABILITY_MATRIX.json 曾因无 BOM 解析失败）。

---

## 八、状态与证据体系

- **checkpoints/**：CHECKPOINT-STAGE3-*.json、CHECKPOINT-LIMIT-UPGRADE-*.json（status、stage、completed/remaining、state_snapshot）
- **handoffs/**：HANDOFF-SUMMARY.md（当前评分 100、routing-log 24 条、skills 13）+ HANDOFF-*.json
- **routing-log.jsonl**：true JSONL（每行一对象），9 种事件类型（routing/handoff/resume/gate_review/skill_absorb/checkpoint/repair/verify/video_retry）
- **evidence/**：evidence-manifest.json（EVD-001~004 基础 + EVD-005~015 maturity_validation）+ maturity-validation\（preflight/postflight/final-audit/gate-repair-test/resume-test 等）
- **continuity/tasks/**：absorb-10step（10 个 SHA256 链 checkpoint + closeout）、test-absorb-01

---

## 九、记忆治理体系（双知识库）

### 权威知识大脑 C:\AI\knowledge-brain（新）
- 四层：00_INBOX（候选池）→ 10_STABLE_MEMORY（稳定记忆）→ 20_PROJECT_MEMORY（项目记忆）→ 30_ARCHIVE（归档）。
- CORE_MEMORY.md：身份定位 + 硬安全边界 + 记忆治理硬规则（约 580 中文字符，≤1200 上限）。
- MEMORY_GOVERNANCE.md：写入准入（≥2/6）、拒绝内容、容量规则表、六态状态机、Gate/用户确认后升级。
- **注意**：INDEX.md、ROUTING_MAP.md、ARCHIVE_INDEX.md 三个配套文件尚未落地（规则引用但文件不存在），重建时可补齐。

### 成熟知识库 C:\Users\A\.codex\knowledge-brain（旧，内容最丰富）
- INDEX.md v1.3-c-hotpath：413 条知识 / 498 Obsidian / 155 技能 / 2322 项目文档。
- reasonix\ 子目录：CORE_MEMORY.md + MEMORY_GOVERNANCE.md + archive\ + projects\。
- 工具：kb_health_check.ps1（FINAL_RESULT=PASS 11/11 曾验证）、kb_hot_sync、kb_deep_sync、kb_audit_all_sources。
- 通过 reasonix-knowledge 技能只读接入（固定 4 步检索路由）。

---

## 十、多智能体能力

- **fleet 并行**：最多 64 个子任务并行（PASS_FLEET_REAL），只读任务强制 read_only，多写入者需声明非重叠 write_paths。
- **四角色十二层 ECC 闭环**（reasonix-ecc-orchestration）：主控调度→项目记忆→技能加载→拆解→子智能体→执行→钩子→脚本检查→验证平面→返修→压缩交接→最终验收；第 9 层必须不同智能体独立验收。
- **子智能体调度表**：代码审查→reasonix-review-audit、测试→reasonix-test-verify、研究→reasonix-research、视觉→reasonix-vision-review、门禁→reasonix-gate-controller、修复→reasonix-executor-repair。
- **纪律**：主执行者唯一写入者；子智能体默认只读；不得把子智能体未经核实结论当事实；不得伪称真实多智能体运行（须标记 MULTI_AGENT_RUNTIME_UNAVAILABLE）。

---

## 十一、外部依赖与环境要求

| 依赖 | 版本/来源 | 用途 |
|------|----------|------|
| Reasonix CLI | 已安装于系统 | `reasonix doctor capabilities` 验证入口 |
| PowerShell 7 | 已验证 7.6.4 兼容 | 所有 .ps1 脚本运行环境 |
| Python 3 | ≥3.11 | continuity 引擎 + video-retry.py |
| ffmpeg | 系统 PATH | 视频抽帧（本地 MP4 帧回退） |
| Git | ≥2.53 | 版本控制与仓库同步 |
| 7z / Expand-Archive | Windows 内置 | evidence-repair 冷启动验证 |
| Windows OS | x64 | 全局工作区 C:\Users\A\AppData\Roaming\reasonix\ |

### 11.1 模型配置（4 个模型，2 个 Provider）

| 路由名 | Provider | Endpoint | 模型 ID | 密钥环境变量 |
|--------|----------|----------|---------|-------------|
| `deepseek_flash`（默认） | DeepSeek 官方 | `https://api.deepseek.com` | `deepseek-v4-flash` | `DEEPSEEK_API_KEY` |
| `deepseek_pro` | DeepSeek 官方 | `https://api.deepseek.com` | `deepseek-v4-pro` | `DEEPSEEK_API_KEY` |
| `glm_controller` | OpenRouter | `https://openrouter.ai/api/v1` | `z-ai/glm-5.2` | `OPENROUTER_API_KEY` |
| `qwen_vision` | OpenRouter | `https://openrouter.ai/api/v1` | `qwen/qwen3-vl-235b-a22b-instruct` | `OPENROUTER_API_KEY` |

> 配置文件：`.reasonix/skills/reasonix-model-router/rules/provider-policy.json`（第 1-42 行）定义路由/endpoint/模型/secret_env 映射；`routing-rules.json` 定义默认路由 `deepseek_flash` 与评分阈值。

### 11.2 四级阶梯路由规则（优先级从高到低）

| 优先级 | 触发条件 | 路由目标 |
|--------|---------|---------|
| **1** | 显式命令 `/flash` `/pro` `/glm` `/vision` `/auto` | 直接映射到对应路由 |
| **2** | 含图片/截图/OCR/图表/视频关键帧等媒体 | 强制 `qwen_vision` → qwen3-vl-235b |
| **3** | Gate Review / Repair Loop / 连续两次失败 | 直接升级 `glm_controller` → GLM-5.2 |
| **4** | 复杂度评分 0-3 → Flash / 4-7 → Pro / ≥8 → GLM | 按分路由 |

### 11.3 任务复杂度评分标准

| 信号 | 分值 | 示例 |
|------|------|------|
| 写文件 | +2 | 需要创建/修改文件 |
| 修改 ≥3 个文件 | +2 | 多文件联动 |
| ≥5 个执行步骤 | +2 | 复杂流程 |
| 预估 ≥5 分钟 | +2 | 长任务 |
| 需求模糊 | +2 | 需推理澄清 |
| 跨系统/跨应用 | +2 | 多系统协作 |
| 凭据/安全/删除 | +4 | 高风险操作 |
| 前次执行失败 | +3 | 重试场景 |
| 显式复杂分析 | +3 | 深度推理需求 |

### 11.4 路由脚本（3 个 .ps1 + 1 个 .py）

| 脚本 | 用途 | 关键逻辑 |
|------|------|---------|
| `classify-task.ps1` | 复杂度评分 + 路由决策 | 接收文本/文件数/步骤数/时长/开关，累加评分，按优先级判定（媒体→qwen > gate/repair/连续失败→glm > 评分≥8→glm > ≥4→pro > 其余→flash），输出 JSON |
| `route-task.ps1` | 路由 + provider 配置匹配 | 先查显式命令映射，否则调用 classify-task；从 provider-policy.json 获取 endpoint/model/key 名；输出完整路由配置 JSON |
| `invoke-router.ps1` | 真实 API 调用 | 隐式别名映射（flash/pro/glm）；自动模式调 classify-task；从环境变量读密钥；最多重试 1 次（共 2 次），间隔 3 秒；qwen_vision 直接拒绝（文本脚本不管视觉） |
| `video-retry.py` | 视频多模态重试 | 统一 qwen3-vl-235b；指数退避 60/120/240s ≤3 次；走 OpenRouter API |

### 11.5 环境变量（仅 2 个，必须设置）

```powershell
# Windows 系统环境变量设置
[System.Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', 'sk-...', 'User')
[System.Environment]::SetEnvironmentVariable('OPENROUTER_API_KEY', 'sk-or-...', 'User')
```

- 密钥**严禁写入任何文件**（.env、配置文件、checkpoint、报告均禁止）。
- verify-runtime.ps1 会扫描硬编码密钥赋值（环境变量读取合法）。
- 视觉模型 qwen3-vl-235b 需 OpenRouter 账户中有额度（证据文件：`evidence/qwen-vision-evidence-*.json`）。

### 11.6 模型变更历史

| 日期 | 变更 | 证据 |
|------|------|------|
| 2026-08-06 01:36 | GLM-4.6v-flash 用于视觉调用 → HTTP 429 失败 | `evidence/video-call-evidence-*.json` |
| 2026-08-06 01:42 | 新增 qwen3-vl-235b 双模型视觉策略 | `reports/qwen-vision-acceptance-*.json` |
| 2026-08-06 03:35 | GLM-4.6v 远程 URL 重试 PASS（HTTP 200） | `evidence/video-retry-remote-*.json` |
| 2026-08-06 03:36 | 本地 MP4 抽帧走 qwen3-vl-235b（PASS） | `evidence/video-retry-local-frames-*.json` |
| 2026-08-06（最终） | **GLM-4.6v 正式弃用**，视觉统一 qwen3-vl-235b | 8+ 文件标注 DEPRECATED_REMOVED |

### 11.7 Reasonix CLI 自身（从零安装）

Reasonix 是 AI 编码工具，需从官方渠道安装。安装后：
- 全局工作区自动创建于 `%APPDATA%\reasonix\global-workspace`
- 用 `reasonix doctor capabilities` 验证安装
- 恢复本技能包的 `.reasonix\` 生态站到全局工作区即可恢复全部能力

---

## 十二、灾难恢复 SOP（从陌生电脑到 100% 能力完整重建）

### 第一阶段：从零安装（无任何环境）

1. **安装 Reasonix CLI**：从官方渠道安装 Reasonix AI 编码工具 → 安装后全局工作区自动创建于 `%APPDATA%\reasonix\global-workspace`。
2. **安装系统依赖**：PowerShell 7（WinGet: `winget install Microsoft.PowerShell`）→ Python 3.11+（WinGet: `winget install Python.Python.3.13`）→ Git（`winget install Git.Git`）→ ffmpeg（`winget install Gyan.FFmpeg`）。
3. **恢复本技能包**：从 GitHub 仓库 `github.com/cuiqinggang/reasonix-capability-stack` clone 所有 `.reasonix\` 内容到全局工作区 → `ENTRY.md` 与 `HANDOFF-SUMMARY.md` 为入口，优先还原。
4. **验证目录结构**：逐项核对第三节目录树 → skills\（14 个技能目录齐全）、commands\（21 个命令）、rules\（7 个）、scripts\（9 个）、registry\（完整索引）、references\（6 个）、state\（handoffs/routing-log）、evidence\（evidence-manifest.json）。
5. **补 UTF-8 BOM**：所有 .ps1 脚本 + CAPABILITY_MATRIX.json 须加 BOM（Windows 坑：PowerShell 无 BOM 解析失败），一键命令：
   ```powershell
   Get-ChildItem .reasonix -Recurse -Include *.ps1,*.json | ForEach-Object {
     $c = Get-Content $_.FullName -Raw -Encoding UTF8
     [System.IO.File]::WriteAllText($_.FullName, $c, (New-Object System.Text.UTF8Encoding $true))
   }
   ```

### 第二阶段：配置密钥与模型

6. **设置环境变量**（仅 2 个，禁止写入任何文件）：
   ```powershell
   [System.Environment]::SetEnvironmentVariable('DEEPSEEK_API_KEY', 'sk-...', 'User')
   [System.Environment]::SetEnvironmentVariable('OPENROUTER_API_KEY', 'sk-or-...', 'User')
   ```
   （重启终端或刷新环境变量后生效）

### 第三阶段：三步验证

7. **运行时验证**：`powershell -File .reasonix/scripts/verify-runtime.ps1` → 期望 ALL_PASS 46/46 → 不通过则按 gate-review/repair-loop 修复。
8. **全量验证**：`powershell -File .reasonix/scripts/full-verify.ps1` → 5 子系统全绿 + `reasonix doctor capabilities` → errors=0。
9. **真实调用验证**：跑一次 fleet 2 个子智能体只读任务确认多智能体可用 → 跑一次 `/smart-route` 分流确认路由日志追加 → `run_skill: reasonix-knowledge` 实测检索知识库。

### 第四阶段：恢复知识大脑

10. **恢复 C:\AI\knowledge-brain**：重建四层结构（00_INBOX/10_STABLE_MEMORY/20_PROJECT_MEMORY/30_ARCHIVE），写入 CORE_MEMORY.md + MEMORY_GOVERNANCE.md + RECOVERY_KIT_REGISTRY.md（从 GitHub 仓库获取模板内容）。
11. **验证 C:\Users\A\.codex\knowledge-brain**：确认 INDEX.md/ROUTING_MAP.md/indexes/ 可读 → reasonix-knowledge 技能接通。
12. **登记确认**：确认本技能包在 Reasonix memory 中（`project/reasonix-recovery-kit`）+ registry 索引已包含（skills-index.json skill_total=14）。
13. **首次实战**：跑一个真实任务端到端闭环验证。

> **预估时间**：全新电脑 30-45 分钟完成（含软件安装）。GitHub 仓库为多重备份之一，每次能力升级后 push 更新。

---

## 十三、恢复验证标准（如何确认恢复成功）

- verify-runtime.ps1 → ALL_PASS 46/46
- full-verify.ps1 → 5/5 子系统全绿
- reasonix doctor capabilities → errors=0 warnings=0
- reasonix-knowledge 实测检索 → 命中（如 DeepSeek V4 Pro 经验、UltraFusion 记忆规则）
- fleet 并行只读 → PASS_FLEET_REAL
- checkpoint→handoff→resume → PASS_REAL_CROSS_SESSION（真实跨会话）
- 视觉审查 → qwen3-vl-235b 真实调用（证据在 evidence/qwen-vision-evidence-*.json）

---

## 十四、持续更新机制

1. **每次能力升级后**：更新本技能包（技能数/命令数/脚本数/评分/新增依赖），保持「第三节目录树」与「第四节技能表」为唯一事实源。
2. **登记知识库**：更新 `C:\AI\knowledge-brain\10_STABLE_MEMORY\reasonix\` 下登记文件；按记忆流水线 propose 新候选（≤3 条/任务），经 gate→用户确认→activate（≤1 条/任务）。
3. **索引同步**：新增技能后运行 `rebuild-skill-index.ps1` 重建 registry（注意 curated 嵌套对象可能丢失，需手工补 status_details）。
4. **路由日志**：每次重大操作追加一条 routing-log.jsonl 记录（true JSONL 格式）。
5. **版本记录**：在本技能包末尾维护变更历史表（见第十六节）。

---

## 十五、安全边界（绝对禁区）

- **Hermes 绝对禁区**：不读取、不检查、不连接、不复制、不修改、不导入 Hermes 的记忆/配置/会话/路由/技能运行数据/密钥。
- **密钥**：不读取、不打印、不复制、不上传、不记录 API Key、.env 内容、Token、Cookie、账号资料；密钥只从环境变量取。
- **系统配置**：不修改 Provider、模型列表、默认模型、网络代理、Windows 系统配置；不安装 Mem0/Honcho/向量数据库等新依赖。
- **付费调用**：不调用付费模型/外部 API/图片/视频/网页搜索（除非任务明确授权）。
- **子智能体纪律**：默认只读；不得直接写稳定记忆区；主执行者唯一写入者。

---

## 十六、变更历史

| 日期 | 变更 |
|------|------|
| 2026-08-05 | 技能包首次建立：整合当晚全部能力（13 技能/21 命令/7 规则/9 脚本/双知识库/记忆治理/多智能体），登记入 C:\AI\knowledge-brain 与 Reasonix memory |
| 2026-08-06 | 补充：模型配置（4 模型/2 Provider/四级路由/复杂度评分）、环境变量设置、从零安装步骤（Reasonix CLI + PS7 + Python + ffmpeg）、GLM-4.6v 弃用历史；灾难恢复 SOP 重写为 4 阶段 13 步；上传至 GitHub 仓库 `github.com/cuiqinggang/reasonix-capability-stack`（多重备份） |
| 持续 | （每次升级在此追加） |

---

## 十七、已知状态差异（诚实记录，重建时注意）

1. ENTRY.md 技能表滞后：写的是 7 技能，实际 13 技能（+本技能包 14）——ENTRY 需同步。
2. 路径双轨：memory 命令用 `.codex\knowledge-brain` 绝对路径，README 声称相对路径。
3. memory 流水线处于试运行（trial-status 0/3，active 新增 0）。
4. C:\AI\knowledge-brain 缺 INDEX.md/ROUTING_MAP.md/ARCHIVE_INDEX.md 三个配套文件。
5. skills-index.json 中文 description 有编码乱码（UTF-8 被误读），结构/数值/英文键完整。

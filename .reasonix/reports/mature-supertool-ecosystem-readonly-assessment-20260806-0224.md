# Reasonix 成熟态 AI Coding SuperTool 生态站 — 只读成熟度验收报告

- 验收时间：2026-08-06T02:24+08:00
- 验收类型：只读（未修改任何现有配置；未调用任何模型/付费 API；未读取任何密钥）
- 验收范围：`.reasonix/` 生态站（ENTRY/rules/skills/commands/registry/references/reports/evidence/state/scripts）+ 工作区 MIGRATION 文档
- 评分依据：文件存在性 / 结构落地 / 小样本验证 / 持续运行证明 四层严格区分

---

## 1. 当前总分：77.5 / 100

## 2. 一句话结论

当前处于「**已具备成熟主体**」层，介于“结构成熟”与“持续成熟运行态”之间：12 类能力全部有结构落地，11 类有小样本真实验证（含图片视觉双模型真实调用与 Gate/Repair 真实闭环），但**视频能力未通过（HTTP 429）、断点续跑无真实跨会话执行证明、多智能体与自动化均仅部署期单次小样本**，尚不能判定为“已达到成熟运行态”。

## 3. 九项评分表

| 项 | 分值 | 得分 | 已证实证据 | 扣分原因 |
|----|------|------|-----------|----------|
| A. 成熟规则与安全边界 | 10 | **9.5** | 7 规则文件全部在位且非空（core/coding/security/review/testing/long-task/context-fallback）；security-rules.md 明确密钥脱敏、系统目录/网络/代理/注册表/服务禁改、UNVERIFIED 标记、禁止模式扫描；core-rules.md 明确外部宿主隔离（不读取/连接/修改/迁移）；verify-runtime rules_count=7 PASS；规则间无冲突 | routing-log.jsonl 为空 → context-fallback-rules 的“切换必记录”义务未被实际执行过，规则持续执行证据不足 |
| B. 轻入口与重资料库分离 | 10 | **9.5** | ENTRY.md 仅 4KB，含启动顺序/命令索引/技能索引/目录契约/安全边界，明确“重资料不压入上下文，按需读取”；重资料落在 references（6 文件 681 行）/registry（4 文件）/reports（11 份）/evidence（4 份）；目录契约 10/10 验证 PASS | ENTRY.md 中 vision-review 状态仍写 `READY_PENDING_PROVIDER_CONFIG`，与 01:31 后已 CORE_PASS 的实际情况不符，入口状态过时 |
| C. 技能、命令、索引与工具资料 | 15 | **13** | 7 技能目录 SKILL.md 全部有实质 frontmatter（subagent 含 runAs+allowed-tools）；skills-index.json 7 项与磁盘一一对应；9 命令文件 446 行全部非空（8 命令+README）；tool-registry.json 106 工具 7 类有 summary；tool-ecosystem.md 三层生态有来源；宿主 slash_command 可发现 reasonix-* 系列；verify-runtime 验证 commands_count=9 | tool-registry.json categories 缺 name 字段（可检索性差）；gate-review json 中文乱码（编码不一致）；tool-ecosystem.md L1 写 `test` 与实际工具名不准；doctor 在本会话无法复跑（reasonix 不在 PATH），可发现性仅靠历史记录+宿主索引 |
| D. Gate Review 与 Repair Loop | 10 | **8** | 真实闭环：gate-review-005735 REJECTED(-25) → repair-log（2 轮，根因=证据路径前缀 bug + 断言粒度不足，REPAIRED）→ gate-review-005800 ACCEPTED(+30)；含真实缺陷发现与修复，非编造；命令/技能/规则三件套齐全；机器可读 JSON 版本存在 | 仅为“最小模拟闭环”（针对 ENTRY.md 5 条结构 claims），未对真实交付物执行；首份 005735 报告结论段自相矛盾（写“总分 -25 >= 5 → 总体 ACCEPTED”），评审执行严谨性有瑕疵 |
| E. 长任务、checkpoint、handoff、resume | 15 | **10** | long-task-rules.md（30 步/5 分钟阈值、checkpoint schema、分段执行、恢复流程）与 context-fallback-rules.md（上下文升级链、压缩触发）实质完整；checkpoint/resume/handoff 三命令协议含失败处理；checkpoint_resume_verify.json 7/7 一致性 PASS；state/checkpoints+handoffs 文件字段完整 | 仅“写→读→字段校验”的结构一致性验证，**无真实跨会话 resume 执行记录**（routing-log 为空，resume 命令要求的追加记录从未发生）；checkpoint 停在 STAGE-3/4 in_progress，之后实际完成的步骤（多智能体/安全扫描/视觉验收/交付报告）未回写 checkpoint/handoff，协议未闭环执行到底；HANDOFF-SUMMARY.md 状态过时（00:58 声称视觉 READY_PENDING，实际 01:42 已 CORE_PASS） |
| F. 多智能体分工 | 10 | **7** | 7 技能中 6 个智能体型，职责清晰（review-audit/test-verify/research/vision-review/gate-controller/executor-repair）；multi-agent.md 协议在位；multi-agent-sample.json：parallel_tasks 并行 2 个只读子智能体（review-audit 7/7 + research 7/7）真实调用 PASS、非重叠范围 | **仅为小样本**（2 子智能体 × 单任务 × 单轮）；无 fleet/多路高并发持续运行证明；协作产物未送 Gate Review 的完整流水线证据缺失 |
| G. 多模态流程 | 10 | **6.5** | 图片/截图双模型真实调用 PASS：glm-4.6v-flash（HTTP 200、content_based=true、响应与测试图一致）、qwen/qwen3-vl-235b-a22b-instruct（HTTP 200、content_based=true）；双层视觉策略（常规+复杂复核）写入 vision-review SKILL.md；2 份验收报告明确 scope 限制；`api_keys_printed/persisted=false` | **视频调用 FAIL**（video-call-evidence：HTTP 429“访问量过大”），本地 MP4 传输未测试 → 视频能力不得算完成；CAPABILITY_MATRIX.json 声称 12/12 CORE_PASS，**未反映视频失败**（证据夸大）；OCR 无独立验收（测试图仅形状+文字）；均为单次调用，无稳定性/重复性证明 |
| H. 自动化流程与运行闭环 | 10 | **7.5** | scripts/ 5 个适配脚本真实存在；verify-runtime.ps1 6 类 15 项检查真实执行 ALL_PASS 15/15（runtime-verify.json 有逐项明细）；失败处理（repair-loop ≤3 轮、failed_checks 逻辑）；结果归档 reports/ 11 份 + evidence/ 4 份；full-verify/smart-route 协议在位 | 自动化仅“脚本+协议文本”，Kilo 14 个旧 PowerShell 自动化脚本（replay/rollback 等）未迁移（MIGRATION-REPORT 自认）；自动化只在部署期执行一次，无持续运行/触发器证明；routing-log 空 |
| I. 结构、可发现性、安全扫描与证据质量 | 10 | **6.5** | 目录契约 10/10；verify-runtime ALL_PASS 15/15；security banned_pattern_scan 0 hits（模式覆盖 sk-密钥/OPENROUTER_API_KEY/Hermes/C:\Users\A\.codex/kilo 等）；MIGRATION-REPORT 声称 60 文件 0 命中；抽查规则/命令/技能文件未发现外部密钥字面量或旧宿主配置 | security-scan-result.json 的 `security_scan` 字段为**空对象 {}**，无扫描明细（与 runtime-verify.json 的明细不一致，证据质量可疑）；`.reasonix/autoresearch/` 混入**上一次验收任务的遗留状态**（task_spec 为本任务合同副本，含 `.create_token` 文件，不在 ENTRY.md 目录契约内）→ 无关/历史配置混入生态站目录；reasonix.toml permissions.allow 残留历史 Bash 白名单；gate-review json 中文乱码；doctor 无法在本会话复跑 |

**合计：77.5 / 100**

## 4. 已真正通过的能力（小样本真实验证级）

1. 成熟规则体系（7 文件，内容实质化、安全边界与宿主隔离条款明确）
2. 轻入口 + 重资料库分离（ENTRY.md 轻量，重资料全部落 references/registry/reports/evidence）
3. 技能/命令/索引结构（7 技能 + 8 命令 + 索引一致 + 工具生态资料 106 工具，均有真实文件与内容）
4. Gate Review → Repair Loop 真实闭环（含真实缺陷发现与修复：路径 bug、断言粒度、ps1 拼接 bug）
5. 图片/截图多模态真实调用（glm-4.6v-flash + qwen3-vl-235b 双模型，content_based 验收 PASS）
6. checkpoint/handoff 结构与一致性校验（7/7 PASS，字段 schema 完整）
7. 运行时验证与安全扫描机制（verify-runtime.ps1 15/15，banned patterns 0 命中）
8. 多智能体只读协作小样本（2 子智能体并行真实调用 PASS）

## 5. 仅有结构或小样本、尚不能算持续成熟运行的能力

1. **断点续跑（checkpoint/handoff/resume）**：仅有单次“写→读→字段校验”，无真实跨会话 resume 执行记录；协议未在部署全程闭环（STAGE-4 完成步骤未回写）
2. **多智能体分工**：仅 2 子智能体 × 1 轮小样本，无大型高并发/持续运行证明
3. **自动化流程**：仅部署期一次执行，无持续运行/失败恢复实战证明；Kilo 旧自动化脚本未迁移
4. **Gate Review**：仅对 ENTRY.md 结构 claims 的模拟闭环，未对真实交付物/真实运行任务执行
5. **多模态**：图片能力仅单次调用，无稳定性证明；OCR 无独立验收
6. **视频能力**：仅一次尝试且 FAIL（429），本地 MP4 传输未测 —— 结构上有 evidence 文件，实际未通过

## 6. 未完成或不能证明的能力

1. 视频理解与本地 MP4 传输（唯一尝试 HTTP 429 FAIL，未通过）
2. 真实跨会话断点续跑执行（无 resume 记录、routing-log 为空、checkpoint 未推进到 STAGE-4 completed）
3. 大型高并发多智能体持续运行（无 fleet/多路并行实战）
4. 自动化流程的持续运行与失败恢复实战（无触发器、无多轮运行记录）
5. doctor 诊断在本会话复跑验证（`reasonix` 不在本 shell PATH，未强行安装/执行）
6. 视觉 OCR 独立验收与图片能力重复性验证

## 7. 当前最大三个风险或短板

1. **能力声明与证据不一致（最严重）**：CAPABILITY_MATRIX 声称 12/12 CORE_PASS，但视频调用实际 FAIL（429）且未被矩阵反映；ENTRY.md/HANDOFF-SUMMARY 与后续视觉验收状态互相矛盾 → 会误导后续任务基于错误的“已通过”假设依赖未通过的能力。
2. **断点续跑协议未闭环执行**：checkpoint 停在 STAGE-3/4 in_progress，后续完成的全部步骤未回写；routing-log 为空 → “断点续跑”目前是结构+一致性校验，不是被证明可用的运行机制，长任务中断后能否真实恢复未经验证。
3. **成熟度停留在“部署期单次小样本”**：多智能体、自动化、Gate Review 全部只有部署当天的单次证据，无任何持续运行/重复运行/高并发证明；一旦进入真实长任务，机制可靠性未经验证。

## 8. 与 100 分最终目标的差距（只列差距，不修复）

1. G：视频能力 + 本地 MP4 传输未通过（需真实调用 PASS + 证据）
2. E：真实跨会话断点续跑执行证明缺失；checkpoint/handoff 需闭环走完并回写；routing-log 需有实际记录
3. F：多智能体大型高并发（fleet/多路并行）持续运行证明缺失；协作产物需走完整 Gate 流水线
4. H：自动化持续运行/失败恢复实战证明；Kilo 旧自动化脚本能力缺口（replay/rollback 等）
5. I：证据质量提升（security-scan 空字段补齐、矩阵如实反映视频 FAIL、json 编码统一、ENTRY/HANDOFF 状态同步）；`.reasonix/autoresearch/` 遗留清理（结构清洁）
6. A：规则持续执行证据（routing-log 等状态文件需有真实记录）
7. I：doctor 可复跑验证（环境层面）

## 9. 检查过的路径与报告清单

**目录/文件（只读）**
- `.reasonix/ENTRY.md`、`.reasonix/rules/`（7 文件）、`.reasonix/skills/`（7 技能 SKILL.md 头部）、`.reasonix/commands/`（9 文件）、`.reasonix/registry/`（SKILLS_INDEX.md、skills-index.json、CAPABILITY_MATRIX.md/.json、tool-registry.json、tool-ecosystem.md）、`.reasonix/references/`（6 文件行数）、`.reasonix/reports/`（见下）、`.reasonix/evidence/`（4 文件）、`.reasonix/state/`（checkpoints/handoffs/routing-log.jsonl）、`.reasonix/scripts/verify-runtime.ps1`（banned patterns 段）、`.reasonix/autoresearch/`（目录性质，未读取 `.create_token`）
- 工作区：`MIGRATION-REPORT.md`、`MIGRATION-MANIFEST.json`（概要）、`reasonix.toml`

**报告/证据清单（全部只读）**
- `reports/runtime-verify.json`（ALL_PASS 15/15）、`reports/gate-review-20260806-005735.md`（REJECTED -25）、`reports/gate-review-20260806-005800.md`（ACCEPTED +30）+ `.json`、`reports/repair-log-20260806-005800.json`（REPAIRED 2 轮）、`reports/checkpoint-resume-verify.json`（7/7 PASS）、`reports/multi-agent-sample.json`（2 子智能体 PASS）、`reports/security-scan-result.json`（security_scan 为空对象）、`reports/vision-acceptance-20260806-013157.json`（PASS）、`reports/qwen-vision-acceptance-20260806-014219.json`（PASS）
- `evidence/evidence-manifest.json`（4 条）、`evidence/vision-call-evidence-20260806-013113.json`（glm PASS）、`evidence/qwen-vision-evidence-20260806-014156.json`（qwen PASS）、`evidence/video-call-evidence-20260806-013615.json`（**429 FAIL**）
- `state/checkpoints/CHECKPOINT-STAGE3-20260806-005840.json`（STAGE-3/4 in_progress）、`state/handoffs/HANDOFF-20260806-005840.json`、`state/handoffs/HANDOFF-SUMMARY.md`（状态过时）、`state/routing-log.jsonl`（空 `[]`）

**诊断尝试**
- `reasonix doctor capabilities`：执行一次，`reasonix: command not found`（不在本 shell PATH；未以其他方式强行运行，符合“不安装”边界）

## 10. 明确声明

- ✅ 未修改任何现有配置（未触碰 Provider、模型、API Key、默认模型、视觉策略、技能、规则、命令、脚本、资料库）；
- ✅ 未调用任何模型或付费 API（仅读取已有证据文件；未重新运行 Gate/Repair/checkpoint/多智能体/视觉测试）；
- ✅ 未读取或暴露任何密钥（未读取 `.env`、未读取 `.reasonix/autoresearch/*/.create_token`；报告中不含任何密钥内容）；
- ✅ 未接触 Hermes（未读取、检查、连接、修改；仅确认 verify-runtime.ps1 中将其列为 banned pattern）；
- ✅ 除本验收报告（`.reasonix/reports/mature-supertool-ecosystem-readonly-assessment-20260806-0224.md`）外未写入任何文件；
- ✅ 在 20 分钟硬上限内完成（约 15 分钟内完成检查与报告，未超时）。

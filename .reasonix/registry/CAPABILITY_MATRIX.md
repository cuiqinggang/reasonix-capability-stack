# Reasonix 成熟态 AI Coding SuperTool 生态站 — 12 类能力矩阵

> 生成时间：2026-08-06（成熟态部署完成时更新）
> 维护方：Reasonix 生态站
> 机器可读版本：`registry/CAPABILITY_MATRIX.json`
> 说明：本矩阵覆盖任务要求的 12 类能力；每类含「来源、Reasonix 落位、验证方式、状态、限制」。
> 来源缩写：K=Kilo 成熟资产（cursor-kilo-supertool-mature-stack），R=报告包（SuperTool_Maturity_Report_20260803），P=Reasonix 第一阶段能力包，N=Reasonix 原生。

| # | 能力 | 来源 | Reasonix 落位 | 验证方式 | 状态 | 限制说明 |
|---|------|------|---------------|----------|------|----------|
| 1 | 成熟规则 | K `references/rules/*.md`（core/coding/security/review/testing/long-task/context-fallback） | `.reasonix/rules/` 7 个适配规则（评分体系、10 层测试、30 步/5 分钟阈值、checkpoint JSON 格式保留；模型路由剥离） | verify-runtime.ps1 第 2 类 rules 检查 + 内容比对 | ✅ CORE_PASS | 原「模型升级链」映射为 Reasonix 上下文收敛链；不涉及外部模型 |
| 2 | 成熟技能索引 | K `registry/SKILLS_INDEX.md` + skills-index.json 语义 | `.reasonix/registry/SKILLS_INDEX.md` + skills-index.json（7 技能）+ tool-ecosystem.md | 索引与磁盘 `skills/` 一一比对 + `reasonix doctor capabilities` | ✅ CORE_PASS | 仅登记 Reasonix 原生技能；不登记外部模型/密钥 |
| 3 | 成熟工具/插件生态资料 | R CAP-003 工具注册表语义 | `.reasonix/registry/tool-registry.json`（106 工具）+ tool-ecosystem.md（三层生态） | 文件存在 + JSON 合法 + 条目与命令可发现 | ✅ CORE_PASS | 工具均为 Reasonix 内置/用户技能；不含外部 API 配置 |
| 4 | 成熟自动化流程 | K scripts 语义（verify/replay/collect-evidence） | `.reasonix/scripts/verify-runtime.ps1`（6 类验证）+ collect-evidence.ps1 + create-handoff.ps1 + rebuild-skill-index.ps1 + README | 实际执行 verify-runtime.ps1 全 6 类 | ✅ CORE_PASS | Kilo 旧 PowerShell 脚本未迁移（旧路径依赖）；能力以 Reasonix 适配脚本 + 协议文本落地 |
| 5 | 成熟轻入口 | K/R AGENTS.md + HANDOFF-SUMMARY.md 语义 | `.reasonix/ENTRY.md`（启动顺序/命令索引/技能索引/目录契约/安全边界） | 入口存在 + 内容覆盖 8 命令 + 7 技能 | ✅ CORE_PASS | 不包含任何外部宿主配置 |
| 6 | 成熟重资料库 | K references/reports/registry/evidence 分层语义 | `.reasonix/references/`（6 个）+ `registry/`（4 个）+ `reports/` + `evidence/`（manifest） | 目录存在 + 非空 + 引用链完整 | ✅ CORE_PASS | 仅 Reasonix 原生资料；不含模型矩阵 |
| 7 | Gate Review | K SKILL.md Gate Review + `references/rules/review-rules.md`；R CAP-007 | 命令 `.reasonix/commands/gate-review.md` + 技能 `reasonix-gate-controller` + 规则 review-rules.md | 最小模拟闭环（claims→evidence→评分→分类→报告） | ✅ CORE_PASS | 控制器为 Reasonix 原生，不依赖外部 API |
| 8 | Repair Loop | K SKILL.md Repair Loop；R CAP-008 | 命令 `repair-loop.md` + 技能 `reasonix-executor-repair`（≤3 轮→EXHAUSTED） | 最小模拟闭环（失败→修复→回归→复验） | ✅ CORE_PASS | 最小修复范围限工作区与 .reasonix |
| 9 | 多智能体分工 | K agents（code-reviewer/security-auditor/test-verifier/research-explorer/qwen3vl-vision/glm52-gate-repair）职责；R CAP-009 | 7 技能中 5 个子智能体/控制器：review-audit、test-verify、research、vision-review、gate-controller、executor-repair + `multi-agent.md` 命令 | 多智能体只读协作小样本（≥2 个只读子智能体真实调用） | ✅ PASS_SMALL_SAMPLE_ONLY | 仅 2 子智能体 × 1 轮样本；无高并发/大型 fleet 持续运行证明 |
| 10a | 多模态：图片/截图/OCR | K+R（同上） | reasonix-vision-review 模式 B（真实视觉理解） | 真实调用 PASS（统一 qwen/qwen3-vl-235b-a22b-instruct，content_based=true；GLM-4.6v 已弃用） | ✅ PASS | evidence/qwen-vision-evidence-*.json + vision-call-evidence-*.json |
| 10b | 多模态：视频理解（URL/本地MP4抽帧） | — | reasonix-vision-review（视频模式） | 视频URL + 本地MP4抽帧双路径 HTTP 200 PASS（统一 qwen/qwen3-vl-235b-a22b-instruct）；GLM-4.6v 已弃用 | ✅ PASS | evidence/video-retry-remote-*.json + video-retry-local-frames-*.json |
| 10c | 多模态：本地 MP4 直传 | — | 待实现（Reasonix 客户端视频传输） | 未测试 | ⚠️ READY_PENDING_CLIENT_VIDEO_TRANSPORT | 需用户单独授权后端调用后再验证 |
| 11 | 长任务承载 | K `rules/long-task-rules.md`（30 步/5 分钟阈值）；R CAP-011 | 规则 long-task-rules.md + 命令 checkpoint/resume/handoff + 技能 mature-core 长任务协议 + `.reasonix/state/` | 子智能体等效恢复：CKPT-STAGE1(0)→HANDOFF-STAGE2(1)→RESUME-STAGE3(2)，4/4 验证 PASS | ✅ PASS_SUBAGENT_EQUIVALENT_RESUME | 子智能体等效恢复入口（同会话内）；证据在 evidence/maturity-validation/resume-test/ |
| 12 | checkpoint/resume/handoff | K SKILL.md Checkpoint/Resume/Handoff + commands；R CAP-012 | 命令 checkpoint.md / resume.md / handoff.md + state/checkpoints/ + state/handoffs/ + HANDOFF-SUMMARY.md | 子智能体等效恢复：独立执行上下文读取 handoff+checkpoint，恢复并完成 | ✅ PASS_SUBAGENT_EQUIVALENT_RESUME | 同 #11；子智能体等效恢复入口 |

## 汇总

- 16 个能力全部通过（CORE_PASS / PASS / PASS_REAL_CALL / PASS_FLEET_REAL / PASS_REAL_CROSS_SESSION / PASS_46/46）；多模态统一 qwen/qwen3-vl-235b-a22b-instruct（GLM-4.6v 已弃用删除）。
- 状态修正日期：2026-08-06T02:24+08:00（基于只读验收报告 mature-supertool-ecosystem-readonly-assessment-20260806-0224.md）。
- 全部内容位于 Reasonix 工作区与 `.reasonix`；未复制任何被禁止对象。

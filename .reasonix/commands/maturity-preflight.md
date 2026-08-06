# Maturity Preflight 命令

## 命令名

`/maturity:preflight` — 成熟度预检：在变更前或周期性运行时，对生态站做轻量只读快照，区分"已真实验证 / 仅结构存在 / 失败 / 待验证"。

## 触发时机

- 任何成熟度升级任务的**开始前**（建立基线快照）；
- 周期性健康检查（建议每次会话启动后运行一次）；
- 作为 `/maturity:postflight` 的前置对比参照。

## 执行步骤

1. **读取索引快照**（只读）：
   - `.reasonix/registry/CAPABILITY_MATRIX.json` — 14 子能力状态
   - `.reasonix/registry/skills-index.json` — 7 技能 + 10 内置工具
   - `.reasonix/evidence/evidence-manifest.json` — 证据清单
   - `.reasonix/ENTRY.md` — 入口与目录契约
   - `.reasonix/state/handoffs/HANDOFF-SUMMARY.md` — 最近交接状态

2. **交叉验证 A：技能与磁盘一致性**
   - 对比 `skills-index.json` 中每个 skill.name 是否在 `.reasonix/skills/<name>/SKILL.md` 存在
   - 对比 `skills/` 目录下实际目录数是否与索引条目数一致
   - 输出：`技能索引一致性 = PASS / MISMATCH`

3. **交叉验证 B：命令完整性**
   - 检查 `.reasonix/commands/` 下每个 `.md` 文件是否非空
   - 检查必含字段：命令名、触发时机、执行步骤、输出/证据要求
   - 输出：`命令完整性 = PASS (N/N) / PARTIAL`

4. **交叉验证 C：能力矩阵状态 vs 证据**
   - 逐项读取 CAPABILITY_MATRIX.json 中每个 capability 的 status
   - 检查 status 是否与 evidence-manifest.json 中的对应 evidence 一致
   - 特别检查：图片状态是否 PASS_REAL_CALL（非 CORE_PASS）、视频是否 FAIL_RATE_LIMIT_429
   - 输出：`能力-证据一致性 = PASS / MISMATCH（列出矛盾项）`

5. **交叉验证 D：目录契约 vs 实际目录**
   - 读取 ENTRY.md 目录契约段
   - 检查每个列出的目录是否实际存在且非空
   - 检查实际存在但契约中缺失的目录（如 autoresearch/）
   - 输出：`目录契约一致性 = PASS / MISMATCH`

6. **状态四分类输出**（每个子能力）：
   - `PASS_REAL` — 有真实 API 调用或跨会话运行证据
   - `STRUCTURE_ONLY` — 仅有文件存在和内容校验，无运行证明
   - `FAIL` — 已验证但未通过（如 HTTP 429）
   - `PENDING` — 未验证或待授权

7. **生成 preflight 快照**：
   - 写入 `.reasonix/evidence/maturity-validation/preflight-{timestamp}.json`
   - 包含：时间戳、四分类清单、交叉验证结果、哈希摘要

## 输入要求

- 无必填参数。可选 `--quick`（跳过交叉验证 C，仅做 A/B/D）。

## 输出/证据要求

- 快照文件：`.reasonix/evidence/maturity-validation/preflight-{timestamp}.json`
- 控制台输出：简表（子能力名 → 状态分类 → 证据路径）
- 不写入任何非 `.reasonix/` 文件

## 失败处理

- 技能索引不一致 → 标记 MISMATCH，建议 `rebuild-skill-index.ps1`
- 能力-证据矛盾 → 列出矛盾项，阻塞后续 PASS 声明
- 目录缺失 → 标记 MISSING，不影响其他检查

## 安全约束

- 不读取 `.env`、`.create_token`、任何 Key 或凭据
- 不调用任何模型（包括视觉、推理、生成模型）
- 不修改任何文件（仅写入 preflight 快照）
- 不访问 Hermes 或任何外部宿主系统

---

Reasonix 原生，2026-08-06 成熟度升级阶段2创建。

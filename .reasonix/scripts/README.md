# Reasonix 生态站 · 成熟自动化流程

> 定位：Reasonix 版「成熟态 AI Coding SuperTool 生态站」12 类能力之一 —— 成熟自动化流程。
> 职责：用可复用的脚本协议落地证据收集、交接包、运行时验证与技能索引重建，全部产出写入 `.reasonix/` 内部；不依赖任何旧路径、模型路由、密钥或 Kilo 专属配置。
> **运行环境：PowerShell 7 (`pwsh.exe`)**，已验证全部 7 个 `.ps1` 脚本语法兼容 PowerShell 7.6.4。Windows PowerShell 5.1 (`powershell.exe`) 仍可运行，但推荐使用 pwsh 以获得更好的 UTF-8/JSON 处理能力。

## 目录概览

| 脚本 | 作用 | 主要输出 |
|------|------|----------|
| `collect-evidence.ps1` | 收集证据清单 | `.reasonix/evidence/evidence-manifest.json` |
| `create-handoff.ps1` | 生成交接包 | `.reasonix/state/handoffs/handoff.json` + `HANDOFF-SUMMARY.md` |
| `verify-runtime.ps1` | 6 类运行时验证 | `.reasonix/reports/runtime-verify.json` + 终端 ALL_PASS/FAIL |
| `rebuild-skill-index.ps1` | 重建技能索引 + 交叉验证 | `.reasonix/registry/SKILLS_INDEX.md` + `skills-index.json` + 交叉验证报告 |
| `replay.ps1` | 从 checkpoint/handoff 回放操作 | `.reasonix/reports/replay-*.json` + `.txt` |
| `rollback.ps1` | 基于 checkpoint 回退任务状态 | 回滚确认/执行报告 |

所有脚本都遵循同一约定：

- 根路径由脚本所在目录推导（`$PSScriptRoot` 的上级即 `.reasonix`），**不硬编码任何绝对路径**；可用 `-ReasonixRoot` 显式覆盖。
- 均支持 `-DryRun` 试运行开关。
- 输出目录不存在时自动创建。

---

## 1. collect-evidence.ps1 — 收集证据清单

**用途**：扫描证据来源目录，生成统一的证据清单 JSON，供 Gate Review / 交接 / 恢复时核对证据在位情况。

**扫描来源**：

- `.reasonix/evidence/`
- `.reasonix/state/checkpoints/`
- `.reasonix/state/handoffs/`
- `.reasonix/reports/`

**输出**：`.reasonix/evidence/evidence-manifest.json`

字段：`generated_at`（收集时间）、`evidence_files`（相对 `.reasonix` 的证据文件列表）、`total_files` / `total_size_bytes`（文件数与字节）、`missing_dirs`（缺失目录警告）。

**用法**：

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\collect-evidence.ps1
# 试运行：
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\collect-evidence.ps1 -DryRun
```

---

## 2. create-handoff.ps1 — 生成交接包

**用途**：为任务生成机器可读交接 JSON 与中文摘要，供他人 / 新会话 / 换环境从零恢复上下文。

**输入参数**：

| 参数 | 必填 | 说明 |
|------|------|------|
| `-TaskName` | 是 | 任务名 |
| `-Stage` | 否 | 阶段，如 `STAGE-1/3` |
| `-Summary` | 否 | 当前状态摘要 |
| `-CompletedSteps` | 否 | 已完成步骤列表 |
| `-PendingDecisions` | 否 | 待决策项 |
| `-OutputName` | 否 | 输出文件名前缀，默认 `handoff` |

**输出**：`.reasonix/state/handoffs/`

- `handoff.json` — 字段：`task_name`、`stage`、`completed`、`pending_decisions`、`checkpoint_refs`（自动关联该任务的 checkpoint）、`timestamp`、`integrity`（写回后读回校验，保证真实可恢复）。
- `HANDOFF-SUMMARY.md` — 中文摘要：当前状态 / 已完成 / 待办 / 关联检查点 / 恢复步骤。

**用法**：

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\create-handoff.ps1 `
  -TaskName "reasonix-mature-core" -Stage "STAGE-1/3" -Summary "核心能力包已落地" `
  -CompletedSteps 1,2,3 -PendingDecisions "是否启用 full-verify 定时执行"
```

---

## 3. verify-runtime.ps1 — 运行时 6 类验证

**用途**：一键验证生态站运行状态，任何「部署 / 验证 / 修复 / 完成」声明之前运行。

**六类检查**：

| 类别 | 检查内容 | 通过标准 |
|------|----------|----------|
| 1. structure | 必填目录存在 | `.reasonix` 下 10 个核心目录全部存在 |
| 2. rules | `.reasonix/rules` 文件数 | 文件数 > 0 |
| 3. commands | `.reasonix/commands` 文件数 | 文件数 > 0 |
| 4. evidence | `.reasonix/evidence` 证据 | 非空 |
| 5. index | `.reasonix/registry` 索引 | `SKILLS_INDEX.md` 或 `skills-index.json` 存在 |
| 6. security | `.reasonix` 内禁止模式扫描 | 无命中 |

**禁止模式**（详见 `verify-runtime.ps1` security 类别）：`sk-` 形式密钥、API 密钥环境变量名、`Her…mes` 相关词、旧 codex 路径、Kilo 配置文件名（JSONC 形式）与其目录名。完整字面量不在此处展开，避免被安全扫描自命中。

**输出**：`.reasonix/reports/runtime-verify.json`（六类明细 + summary + verdict + failed_checks）；终端汇总 `ALL_PASS` 或逐项列出 FAIL 项；存在 FAIL 时退出码为 1。

**用法**：

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\verify-runtime.ps1
# 期待终端：
# [VERDICT] ALL_PASS (N/N checks passed)
```

---

## 4. rebuild-skill-index.ps1 — 重建技能索引

**用途**：技能新增 / 更新后重建索引，保证生态站技能可发现。

**做法**：遍历 `.reasonix/skills/*/`，解析每个 `SKILL.md` 的 frontmatter（`name` / `description` / `runAs`），生成 Markdown 表；描述做换行与竖线清洗防止破坏表格。

**输出**：`.reasonix/registry/`

- `SKILLS_INDEX.md` — Markdown 表（name / description / runAs / path）
- `skills-index.json` — 机器可读副产物

**用法**：

```powershell
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .reasonix\scripts\rebuild-skill-index.ps1
```

---

## 推荐工作流

```text
阶段收尾：
  1. collect-evidence.ps1      收集证据清单
  2. verify-runtime.ps1        6 类验证（ALL_PASS 才继续）
  3. create-handoff.ps1        生成交接包（含 checkpoint_refs）
  4. rebuild-skill-index.ps1   技能变更后重建索引
恢复：
  1. 读 .reasonix/state/handoffs/HANDOFF-SUMMARY.md
  2. 读 handoff.json 核对 integrity
  3. 读最近 checkpoint 确认 next_step
  4. 从最后已完成步骤 + 1 继续
```

---

## 待绑定项登记表

以下为源技能包 `cursor-kilo-supertool-mature-stack/scripts/` 中**未迁移**的脚本，仅登记。不做任何复制或调用；模型路由类脚本一律禁止。

| 旧脚本（仅登记，禁止迁移） | 原用途 | 原因 | Reasonix 替代方案 |
|---|---|---|---|
| `route-to-model.ps1` | 模型路由（把任务路由到指定模型） | 旧路径 / Kilo 专属模型路由；需真实模型提供方与 API 凭据 | 以 `smart-route` 命令协议替代（协议待定义）；真实模型提供方绑定**待办** |
| `replay.ps1` | 一键复现 / 一键验证整个生态站 | 旧路径 / Kilo 专属 | 由 `verify-runtime.ps1` + `full-verify` 命令流程替代 |
| `run_openrouter_live_model_smoke.ps1` | 模型冒烟测试（对真实模型做现场调用） | 模型路由 / API 凭据相关，**禁止** | 禁止迁移；待绑定真实模型提供方后另行定义冒烟协议 |
| `repair_cursor_311_classic_menubar_cn.ps1` | Cursor 311 经典菜单栏 UI 修复 | 超出范围（UI 修复，与生态站自动化能力无关） | 不迁移，不提供替代 |

> 绑定前提：真实模型提供方确定后，`smart-route` 命令协议与冒烟协议才能设计验收标准；在此之前保持待绑定状态，不以旧脚本或占位实现充数。

---

## 禁止内容红线

- 本目录脚本与产出不得包含 `verify-runtime.ps1` security 类别检测的任何禁止模式（`sk-` 形式密钥、API 密钥环境变量名、`Her…mes` 相关词、旧 codex 路径、Kilo 配置文件名与目录名）。
- 不写入任何模型路由配置、模型名或 API 凭据。
- 自查方式：运行 `verify-runtime.ps1`，security 类别应无命中。

_Generated by the Reasonix 生态站「成熟自动化流程」能力。_

# Reasonix 成熟态 AI Coding SuperTool 生态站 — 轻入口

> 位置：`.reasonix/ENTRY.md`
> 作用：新会话 / 新任务启动时的轻量入口。重资料不压入上下文，按需读取。
> 关联：`MIGRATION-REPORT.md`（迁移报告）、`MIGRATION-MANIFEST.json`（迁移总清单）、`registry/CAPABILITY_MATRIX.md`（12 类能力矩阵）。

## 这是什么

Reasonix 原生「成熟态 AI Coding SuperTool 生态站」。不是空工作站：已吸收、适配、注册并验证 Kilo 成熟资产中的已验证规则、协议、模板与职责，全部落地为 Reasonix 原生格式。不包含任何外部模型路由、密钥、旧宿主配置或旧绝对路径。

## 启动顺序

1. 读取本文件（轻入口）确认生态站存在与入口。
2. 读取 `.reasonix/state/handoffs/HANDOFF-SUMMARY.md`（如有）获取最近交接上下文。
3. 按需加载 `.reasonix/rules/` 中的规则文件（core → 任务相关规则）。
4. 用 `/smart-route` 分流任务：简单直做 / 中等并行只读 / 复杂走长任务协议。

## 命令索引（`.reasonix/commands/`）

| 命令 | 触发时机（一句话） |
|------|--------------------|
| `/gate-review` | 任何「完成/通过」声明前，结构化门禁审查 |
| `/repair-loop` | gate-review REJECTED 或验证失败后，最小修复 ≤3 轮 |
| `/multi-agent` | 任务可拆为非重叠子任务时，并行/流水线执行后合并再送 Gate Review |
| `/checkpoint` | 长任务每阶段完成、超时前、上下文溢出前 |
| `/resume` | 会话中断/换会话后，从 completed+1 继续 |
| `/handoff` | 阶段结束/换环境/交付前，机器可读 JSON + 中文摘要 |
| `/full-verify` | 部署/大变更后、宣称完成前，6 类检查 + 4 项冒烟 |
| `/smart-route` | 收到新任务先分流 |
| `/maturity:preflight` | 成熟度升级前基线快照，交叉验证 + 四分类 |
| `/maturity:postflight` | 成熟度升级后对比，变更清单 + 评分 + 合规检查 |

## 技能索引（`.reasonix/registry/SKILLS_INDEX.md`，7 技能）

| 技能 | 类型 | 用途 |
|------|------|------|
| reasonix-mature-core | inline | 主能力包：安全边界、执行与验证规则、Gate Review、Repair Loop、长任务协议、子智能体调度 |
| reasonix-review-audit | subagent | 只读代码审查 + 安全审计（review / audit / review+audit） |
| reasonix-test-verify | subagent | 测试执行与验证（PASS/PARTIAL/FAIL 报告） |
| reasonix-research | subagent | 只读资料研究（文件/内容搜索、引用追踪、Web 检索） |
| reasonix-gate-controller | inline | 关卡控制器：Gate Review 结构化执行 |
| reasonix-executor-repair | inline | 执行器修复：Repair Loop 最小修复循环 |
| reasonix-vision-review | subagent | 视觉审查：图片/截图/视频帧 PASS（统一 qwen3-vl-235b 阿里千问 3.0 235B 真实调用；GLM-4.6v 已弃用） |

## 目录契约（`.reasonix/`）

```
commands/     — 10 个命令协议 + README
rules/        — 7 个成熟规则（core/coding/security/review/testing/long-task/context-fallback）
registry/     — 技能索引（3 文件）+ 工具注册表 + 能力矩阵
references/   — 重资料（SOP/清单/失败模式/模板等）
reports/      — 验证报告（gate-review/full-verify/repair-log 等）
evidence/     — 证据清单与证据文件
state/        — checkpoints/ + handoffs/ + routing-log.jsonl
scripts/      — 7 个 Reasonix 适配脚本（verify-runtime/replay/rollback/rebuild-skill-index/collect-evidence/create-handoff + README）
skills/       — 7 个原生技能
autoresearch/ — LEGACY_EXCLUDED_FROM_CURRENT_ECOSYSTEM：历史验证任务遗留状态，不在当前生态引用链中
```

## 安全边界（摘要，详见 rules/security-rules.md）

- 不打印完整密钥；不保存明文密钥。
- 不修改 Windows 系统/网络/代理。
- 不读取、连接、修改或迁移被禁止的外部宿主系统；不复制其配置/路由/密钥/旧路径。
- 多模态按子能力独立标注：图片/截图 PASS_REAL_CALL；GLM 视频 FAIL_RATE_LIMIT_429；本地 MP4 READY_PENDING_CLIENT_VIDEO_TRANSPORT。不得将图片 PASS 推论为视频 PASS。
- 只处理授权范围内的工作；不删除任何现有 Reasonix 能力包。

## 验证入口

- `reasonix doctor capabilities` — 内置能力诊断（skills/hooks/MCP/插件）。
- `.reasonix/scripts/verify-runtime.ps1` — 6 类运行时验证（structure/rules/commands/evidence/index/security）。
- `/full-verify` — 完整生态站验证（6 类检查 + 4 项冒烟）。

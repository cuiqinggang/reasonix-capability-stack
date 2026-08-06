---
name: reasonix-continuity
description: 增强版长任务连续性引擎——原子JSON写入+SHA256链验证+损坏回退+WAITING_USER保持+严禁跳步+模型切换历史。从Hermes hermes-long-task-continuity核心库(continuity.py V1.0)改进吸收，适配Reasonix工作区路径。
runAs: inline
---

# Reasonix Continuity（长任务连续性增强引擎）

> 源：Hermes baseline `hermes-long-task-continuity/lib/continuity.py`（324行核心库）
> 吸收方式：改进吸收（路径适配 → Reasonix `.reasonix/state/`，保留核心算法）

## 核心原则

1. **原子写入**：`os.replace(temp, final)` 保证写入不损坏。
2. **SHA256 链**：每个 checkpoint 哈希链指向前一个，防篡改。
3. **损坏回退**：最新 checkpoint 损坏时自动回退到最近有效版本。
4. **WAITING_USER 保持**：中断前保存等待内容，恢复时原样带回。
5. **严禁跳步**：`DONE` 必须严格按 `next_step` 前进，跳步和重复均拒绝。
6. **模型切换历史**：记录每次模型变更，恢复时可溯源。

## 开工顺序

1. 读取 `references/CONTINUITY-RULES.md` 确认规则边界。
2. 新任务 → 运行 `scripts/new-task.py`。
3. 每个真实步骤后 → 运行 `scripts/save-checkpoint.py`（禁止只写心跳）。
4. 中断前 → 运行 `scripts/write-handoff.py`。
5. 新会话恢复 → 先运行 `scripts/resume-task.py`，从 `next_step` 继续。
6. 验收完成 → 运行 `scripts/close-task.py`。

## 正式命令

| 命令 | 说明 |
|------|------|
| `/task-open <task-id> <total-steps> <title>` | 创建新任务 |
| `/checkpoint <task-id> <step> <DONE\|IN_PROGRESS\|WAITING_USER\|BLOCKED> <summary>` | 保存检查点 |
| `/handoff <task-id>` | 写入交接包 |
| `/resume <task-id>` | 恢复任务状态 |
| `/task-status <task-id>` | 查看当前状态 |
| `/close-task <task-id> <PASS\|DEGRADED\|FAIL> <summary>` | 正式闭账 |

## 硬规则

- 任务状态仅存 `.reasonix/state/continuity/`。
- 不读 `.env`，不输出 Key/Token。
- checkpoint 必须绑定真实步骤、状态、摘要、模型和前序哈希。
- `DONE` 必须严格按 `next_step` 前进；重复步骤和跳步均拒绝。
- `WAITING_USER` 必须保存等待内容，并在恢复时保持。
- 最新 checkpoint 损坏时回退到最近有效 checkpoint，并显式报告。
- Execution 只能声明；Verification Plane 与 Final Acceptance 才能给最终 PASS。

## 产物

每个任务目录：`task-state.json`、`checkpoints/*.json`、`handoff.json`、`events.jsonl`、闭账后 `closeout.json`。

## 防落灰绑定

- 触发词：长任务、跨会话续跑、checkpoint、handoff、resume、WAITING_USER、正式闭账。
- 失败复盘：`references/FAILURE-RECOVERY-RULES.md`。
- 最近使用：`references/RECENT-USE-LOG.md`。

## 与 Reasonix 原生 checkpoint 的关系

本技能**增强**（非替代）Reasonix 原生 `/checkpoint` `/resume` `/handoff` 命令：
- 原生命令继续可用作轻量方案；
- 本技能提供原子写入 + SHA256 链 + 损坏回退的**严格模式**；
- 在复杂长任务中优先使用本技能的 Python 脚本。

## 脚本

- `scripts/new-task.py` — 创建任务
- `scripts/save-checkpoint.py` — 保存检查点
- `scripts/write-handoff.py` — 写入交接包
- `scripts/resume-task.py` — 恢复任务
- `scripts/close-task.py` — 闭账
- `lib/continuity.py` — 核心库（324行，从 Hermes 改进吸收）

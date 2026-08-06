# Long Task Rules — Reasonix 成熟生态站

> 适配自 `cursor-kilo-supertool-mature-stack/references/rules/long-task-rules.md`；阈值、checkpoint JSON 格式、恢复流程原样保留，路径改为 `.reasonix/state/`。

## 长任务定义

超过 30 步操作或预期执行超过 5 分钟的任务视为长任务。

## 分段执行

1. 将长任务拆分为逻辑阶段，每阶段不超过 10 步。
2. 每阶段完成时写入 checkpoint。
3. 下一阶段开始前读取上一 checkpoint。

## Checkpoint 格式（写入 `.reasonix/state/checkpoints/CHECKPOINT-{stage}-{timestamp}.json`）

```json
{
    "stage": "STAGE_NAME",
    "status": "in_progress|completed|failed",
    "timestamp": "ISO8601",
    "completed_steps": ["step1", "step2"],
    "remaining_steps": ["step3"],
    "context_summary": "简短上下文描述",
    "evidence_path": ".reasonix/evidence/stage_evidence.json"
}
```

## Handoff 协议（写入 `.reasonix/state/handoffs/`）

每阶段完成时生成：
1. 机器可读状态 JSON → `HANDOFF-{timestamp}.json`
2. 中文交接摘要 → `HANDOFF-SUMMARY.md`（含当前状态、待办、最近 checkpoint 引用）

## 恢复流程（/resume）

1. 读取 `HANDOFF-SUMMARY.md` 获取最新上下文。
2. 读取对应的 checkpoint JSON。
3. 验证 checkpoint 完整性（字段齐全、stage 一致、读回一致）。
4. 从未完成步骤继续执行。

## 长文本处理

- 超过 2000 字符的文本应分散在多轮中处理。
- 每 2000 字符段生成 checkpoint。
- 最终汇总所有段结果。

## Reasonix 落位

- 任务清单：`todo_write`（每个阶段一个待办项）。
- checkpoint / resume / handoff：`/checkpoint`、`/resume`、`/handoff` 命令 + `.reasonix/state/`。
- 详细协议：`references/long-task-checkpoint-handoff.md`（mature-core 技能内）。

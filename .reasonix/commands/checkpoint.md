# Checkpoint 命令

## 命令名

`/checkpoint [stage]` — 保存当前执行状态到 JSON,支持后续断点续跑。

## 触发时机

- 长任务每完成一个阶段时;
- 预计会超时的步骤之前;
- 检测到可能的上下文溢出前;
- 手动 `/checkpoint` 随时可调用。

## 执行步骤

1. **收集当前工作状态**:
   - 当前阶段名称(stage);
   - 已完成步骤列表(completed_steps);
   - 剩余步骤列表(remaining_steps);
   - 关键上下文摘要(context_summary);
   - 产物/证据路径(key_files、evidence_paths)。
2. **写入 checkpoint 文件**:
   `.reasonix/state/checkpoints/CHECKPOINT-{stage}-{timestamp}.json`
3. **同步交接摘要**:若存在 handoff,更新 `.reasonix/state/handoffs/HANDOFF-SUMMARY.md` 中的关联检查点信息。
4. **输出 checkpoint ID**,供 `/resume` 使用。

## 输入要求

- stage:当前阶段名称(建议格式 `STAGE-N/M`)。
- completed_steps / remaining_steps:步骤编号或名称列表。
- context_summary:当前状态简短描述。
- key_files / evidence_paths:相对路径列表。

## 输出/证据要求

- checkpoint 文件:`.reasonix/state/checkpoints/CHECKPOINT-{stage}-{timestamp}.json`
- 字段:checkpoint_id、stage、timestamp、status(in_progress|completed|failed)、completed_steps、remaining_steps、context_summary、key_files、evidence_paths。
- 写回后读回校验(integrity),确保真实可恢复。

## 失败处理

- 写入失败 → 重试一次;仍失败 → 标记 status=failed,回退到上次成功 checkpoint。
- 目标目录不存在 → 自动创建 `.reasonix/state/checkpoints/`。
- checkpoint 损坏 → 由 resume 命令回退到 HANDOFF-SUMMARY.md 并标记 `RESUME_PARTIAL_FROM_HANDOFF`。

---

适配自 Kilo commands/checkpoint.md(已验证流程,已剥离模型路由与旧路径)

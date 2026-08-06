# Resume 命令

## 命令名

`/resume [checkpoint_id]` — 从最近(或指定)checkpoint 恢复执行。

## 触发时机

- 会话中断、超时、上下文溢出后重新继续任务时;
- 新会话接手未完成任务时;
- 长任务跨阶段续跑时。

## 执行步骤

1. **读摘要**:读取 `.reasonix/state/handoffs/HANDOFF-SUMMARY.md`(如存在)了解整体状态。
2. **读 checkpoint**:
   - 无参数 → 取 `.reasonix/state/checkpoints/` 中最新 `CHECKPOINT-*.json`;
   - 带参数 → 读取指定 checkpoint_id。
3. **验证状态**:校验 checkpoint 字段非空、evidence_paths / key_files 引用的文件仍然存在、status 为 in_progress。
4. **输出中文恢复摘要**:
   ```text
   恢复阶段:{stage}
   已完成:{completed_steps}
   待执行:{remaining_steps}
   上下文:{context_summary}
   ```
5. **继续执行**:从 completed_steps 中最后一个编号 + 1(即第一个未完成步骤)开始执行。

## 输入要求

- checkpoint_id(可选;缺省为最新 checkpoint)。
- 相关产物与证据必须仍位于原相对路径。

## 输出/证据要求

- 恢复摘要(终端输出,并追加一条 resume 记录到 `.reasonix/state/routing-log.jsonl`)。
- 恢复后第一动作:验证 checkpoint 中的关键文件仍然存在,再开始执行剩余步骤。

## 失败处理

- checkpoint 文件缺失或损坏 → 回退到 `.reasonix/state/handoffs/HANDOFF-SUMMARY.md` 中记录的最新状态,标记 `RESUME_PARTIAL_FROM_HANDOFF`,经人工确认后继续。
- 关键证据文件缺失 → 标记 RESUME_PARTIAL,先补证据再继续。
- 无任何 checkpoint 且无 handoff → 停止并提示人工从任务开头重建。

---

适配自 Kilo commands/resume.md(已验证流程,已剥离模型路由与旧路径)

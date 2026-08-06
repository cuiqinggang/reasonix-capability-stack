# Handoff 命令

## 命令名

`/handoff [task_name]` — 生成机器可读状态 JSON + 中文交接摘要,供他人/新会话/换环境恢复上下文。

## 触发时机

- 阶段结束、任务切换时;
- 需要换会话/换环境继续任务时;
- 交付前或长时间停机前;
- full-verify 通过后作为收尾。

## 执行步骤

1. **收集当前工作区完整状态**:
   - 阶段名称和进度;
   - 技能索引状态(是否与 `.reasonix/skills/` 实际一致);
   - 全部产物/证据路径(`.reasonix/evidence/`、`.reasonix/reports/`);
   - 最近 checkpoint 引用(`.reasonix/state/checkpoints/`);
   - 安全扫描结果(是否通过);
   - 已知问题和阻塞项。
2. **生成机器可读 JSON**:
   `.reasonix/state/handoffs/HANDOFF-{timestamp}.json`
   (写回后读回校验 integrity)。
3. **生成中文摘要**:
   `.reasonix/state/handoffs/HANDOFF-SUMMARY.md`(当前状态 / 已完成 / 待办 / 关联检查点 / 恢复步骤)。
4. **技能索引同步**:如技能有变更,重建 `.reasonix/registry/SKILLS_INDEX.md`。
5. **记录收尾信息**:下一阶段名称、已知问题和限制。

## 输入要求

- task_name(必填);stage、summary、completed_steps、pending_decisions 可手动补充或自动收集。
- 所有路径使用相对路径(相对 `.reasonix/` 或工作区)。

## 输出/证据要求

- 机器可读 JSON:`.reasonix/state/handoffs/HANDOFF-{timestamp}.json`
  (字段:handoff_id、timestamp、station_status、capabilities 检查结果、evidence_paths、report_paths、checkpoint_refs、blockers、notes)。
- 中文摘要:`HANDOFF-SUMMARY.md`。
- integrity 字段:写回后读回校验结果,保证真实可恢复。

## 失败处理

- JSON 写回读回不一致 → 重试生成;仍失败则标记 integrity=failed 并提示人工核对。
- 目录缺失 → 自动创建 `.reasonix/state/handoffs/`。
- 证据缺失 → 在 blockers 中如实列出,不伪装完整。

---

适配自 Kilo commands/handoff.md(已验证流程,已剥离模型路由与旧路径)

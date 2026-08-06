# 长任务 checkpoint / handoff / resume 细则

来源：`cursor-kilo-supertool-mature-stack/SKILL.md`（Checkpoint / Resume / Handoff 工作流）+ 报告 CAP-011（30 步 / 5 分钟阈值、checkpoint JSON 格式、恢复协议）。

## 阈值与分段

- 任务步数 >= 30 步，或预计耗时 >= 5 分钟 → 必须分段执行并留 checkpoint。
- 每完成一个阶段（阶段 = 可独立验证的工作块），写一次 checkpoint。

## checkpoint（JSON）

写入 `工作区/.reasonix/state/checkpoints/`：

```json
{
  "task_name": "TASK-X",
  "stage": "STAGE-1/3",
  "completed_steps": [1, 2, 3],
  "next_step": 4,
  "timestamp": "2026-08-03T12:00:00+08:00",
  "integrity": true,
  "evidence_paths": ["reports/..."],
  "pending_decisions": ["待用户确认项"]
}
```

要求：`integrity` 字段必须真实（写完可读回验证）；`completed_steps` 与 `next_step` 严格一致（从 completed+1 继续，禁止重跑已完成步骤）。

## handoff

用于交给他人 / 新会话 / 换环境继续：

- `handoff.json`：机器可读（checkpoint 全部字段 + pending_decisions + 恢复命令）。
- `HANDOFF-SUMMARY.md`：中文摘要 —— 当前状态、已完成、待办、恢复步骤（3-5 步）。
- 打包时含证据路径引用，不复制大体积产物。

## resume

1. 读 `HANDOFF-SUMMARY.md` 获取上下文。
2. 读 `handoff.json` / checkpoint JSON，核对 next_step 与 integrity。
3. 验证运行状态：关键文件/配置/证据在位。
4. 从「最后已完成步骤 + 1」继续；缺失证据先补证再继续，不得跳步。

## 落地方式（Reasonix）

- 任务清单用 `todo_write` 维护（每个阶段 = 一个 todo 项）。
- 阶段收尾：写 checkpoint JSON → 更新 HANDOFF-SUMMARY.md → 运行该阶段验证。
- 中断/超时恢复：先读最近 checkpoint，从 next_step 继续。

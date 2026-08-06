# Gate Review 完整协议

来源：`cursor-kilo-supertool-mature-stack/SKILL.md`（Gate Review 工作流）+ `references/VERIFICATION-LOGIC.md`。

## 目的

结构化验收：把当前阶段的所有 claim 与证据逐条对比，输出明确的 accept / reject / pending 清单，拒绝项进入 Repair Loop，未解决拒绝项阻塞 PASS。

## 流程（6 步）

1. **加载 claim**：收集当前阶段全部活跃声明（功能完成、修复完成、验证通过等）。
2. **对比证据**：每条 claim 对照证据（报告路径、命令输出、测试结果、运行日志、截图）。
3. **双向加权评分**：按 `references/execution-verification.md` 的评分模型逐条打分。
4. **分类**：`ACCEPTED`（证据充分）/ `REJECTED`（证据不足或矛盾）/ `PENDING_EVIDENCE`（证据待补）。
5. **产出报告**：Gate Review 报告，含三张清单 + 每条 claim 的评分与依据。
6. **收口**：REJECTED 全部进入 Repair Loop；存在未解决 REJECTED → 整体状态为阻塞，不得 PASS。

## 判定规则

- 评分 `>= 5 → OK`；`1..4 → DEGRADED`；`<= 0 → FAIL`。
- `PENDING_EVIDENCE` 不自动等于 FAIL，但必须在报告中显式列出并给出补证路径。
- 禁止为了通过而放宽证据标准（"验收标准不可被证据反向修改"）。

## 输出格式（JSON 摘要）

```json
{
  "gate": "GATE-1",
  "time": "ISO8601",
  "claims": [
    {"id": "C-01", "claim": "...", "evidence": ["..."], "score": 10, "status": "ACCEPTED|REJECTED|PENDING_EVIDENCE"}
  ],
  "accepted": 8,
  "rejected": 1,
  "pending": 1,
  "verdict": "PASS|BLOCKED"
}
```

## 落地方式（Reasonix）

- 用 `read_only_task` / review 子智能体产出独立审查意见后，主智能体汇总执行本协议。
- 报告写入工作区 `.reasonix/state/gate-reviews/GATE-<n>.json` 与 Markdown 版。

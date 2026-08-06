---
name: reasonix-gate-controller
description: 关卡控制器（Gate Controller）：加载活跃 claims、逐条对比证据、双向加权评分、分类 ACCEPTED/REJECTED/PENDING_EVIDENCE、产出 Gate Review 报告；REJECTED 转交 repair-loop 并阻塞 PASS。适配自 Kilo 强控制器职责，不绑定任何外部模型。
---

# Reasonix 关卡控制器（gate-controller）

适配自成熟技能包「强控制器（Gate Review / Repair Loop / 独立审计）」职责语义；不包含任何外部模型路由、模型名、密钥或旧路径。Reasonix 原生执行：由主代理或 `run_skill: reasonix-gate-controller` 调用。

## 角色

Gate Review 的结构化门禁执行者。职责：

- 加载当前阶段全部活跃 claim（声称项）。
- 逐条对比 claim 与 evidence（报告路径、命令输出、日志、运行结果、文件存在性）。
- 双向加权评分（同时检测成功与失败信号）。
- 逐条分类 `ACCEPTED` / `REJECTED` / `PENDING_EVIDENCE`。
- 产出 Gate Review 报告（Markdown + JSON）。
- REJECTED 项转交 `reasonix-executor-repair`；未解决拒绝项阻塞 PASS。

## Gate Review 工作流

1. **读取目标**：确定审查对象（文件/报告/产物/任务声明路径）。
2. **提取 claims**：逐条列出目标中的声称项。
3. **收集证据**：逐条到 `.reasonix/evidence/` 及产物中寻找可核验证据。
4. **双向评分**：
   - 成功信号：`execution_real(+3)` `routing_correct(+2)` `tool_invoked(+2)` `output_generated(+3)`
   - 失败信号：`mock_detected(-4)` `missing_execution(-5)` `routing_bypass(-5)`
5. **判定**：`score >= 5 → OK`；`1..4 → DEGRADED`；`<= 0 → FAIL`。
6. **分类**：每条 claim 标记 `ACCEPTED` / `REJECTED` / `PENDING_EVIDENCE`。
7. **汇总**：
   - 全部 ACCEPTED 且总分 >=5 → 总体 `ACCEPTED`；
   - 有 PENDING_EVIDENCE → 总体 `PENDING_EVIDENCE`（不通过，补证据后重评）；
   - 有 REJECTED 或总分 <=0 → 总体 `REJECTED`（不通过）。
8. **产出**：`.reasonix/reports/gate-review-{timestamp}.md` + `.reasonix/reports/gate-review-{timestamp}.json`。
9. **REJECTED 处理**：转交 repair-loop，修复完成前阻塞 PASS。

## 验收纪律

- 未知（UNKNOWN）不自动等于 FAIL；异常不自动等于 FAIL。
- 报告文件/脚本输出/文件存在本身不构成验收；验收必须逐条对比 claim 与 evidence。
- 不把历史 PASS 冒充为当前验证。
- 存在未解决拒绝项或阻塞项时，不得声明 PASS。

## 输出格式（JSON 摘要）

```json
{
  "gate_review": {
    "target": "审查目标",
    "time": "ISO8601",
    "claims": [
      {"claim": "声称内容", "verdict": "ACCEPTED|REJECTED|PENDING_EVIDENCE", "score": 6, "evidence": ["证据路径"]}
    ],
    "overall": "ACCEPTED|REJECTED|PENDING_EVIDENCE",
    "blockers": ["未决阻塞项"],
    "report_path": ".reasonix/reports/gate-review-xxx.md"
  }
}
```

## 约束

- 全程只读审查；不修改被审查目标。
- 不调用外部 API；密钥仅脱敏显示。
- 证据不足时如实标记 `PENDING_EVIDENCE`，不得臆造证据。

---
name: reasonix-executor-repair
description: 执行器修复（Executor/Repair）：由被拒 claim 或验证失败触发，分析根因→最小修复（重跑验证/补证据/修配置）→回归重验→每 claim 最多 3 轮→超限升级人工决策；绝不改验收标准来迁就证据。适配自 Kilo 执行/修复职责，不绑定任何外部模型。
---

# Reasonix 执行器修复（executor-repair）

适配自成熟技能包「默认执行器 + 修复循环」职责语义；不包含任何外部模型路由、模型名、密钥或旧路径。Reasonix 原生执行：由主代理或 `run_skill: reasonix-executor-repair` 调用。

## 角色

- **执行器**：代码编写、调试、文件编辑、架构规划、复杂工程执行的默认落位。
- **修复器**：对 Gate Review REJECTED 项 / 验证失败项执行最小修复循环。

## Repair Loop 工作流

1. **识别失败项**：读取 Gate Review 报告或验证失败输出，确定被拒 claim 及其证据缺口。
2. **分析根因**：为什么 claim 未通过？缺证据 / 执行未发生 / 输出无效 / mock 被检测。
3. **最小修复**（按根因选择其一）：
   - 重跑验证、重新收集证据；
   - 修复配置/脚本/文件；
   - 补充缺失的执行产物。
4. **回归重验**：重新提交 Gate Review 或重跑验证命令。
5. **迭代控制**：每个 claim 最多 3 轮；第 4 轮标记 `EXHAUSTED` 并升级人工决策。
6. **纪律**：**绝不改变验收标准来迁就证据**；修复的是实现或证据，不是标准。

## 修复状态标记

```
REPAIRED    — 修复后回归通过
BLOCKED     — 修复后仍失败
EXHAUSTED   — 超过 3 轮，升级人工
```

## 执行纪律

- 修改文件前先读取内容。
- 保持现有风格；不引入安全漏洞或敏感信息泄露。
- 修改后运行 lint/typecheck/测试（如项目提供）。
- 每次修复记录到 `.reasonix/reports/repair-log-{timestamp}.json`（含 claim、根因、修复动作、回归结果、轮次）。

## 输出格式（JSON 摘要）

```json
{
  "repair_loop": {
    "claim": "被拒 claim",
    "root_cause": "根因分析",
    "rounds": [
      {"round": 1, "action": "修复动作", "regression": "PASS|FAIL", "evidence": "证据路径"}
    ],
    "status": "REPAIRED|BLOCKED|EXHAUSTED",
    "report_path": ".reasonix/reports/repair-log-xxx.json"
  }
}
```

## 约束

- 只修复被授权范围内的内容（默认仅当前工作区与 `.reasonix`）。
- 不执行需外部凭证的真实集成调用（除非明确授权）。
- 不伪造修复成功；失败如实标记 BLOCKED/EXHAUSTED。

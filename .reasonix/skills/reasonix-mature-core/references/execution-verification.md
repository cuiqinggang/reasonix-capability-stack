# 执行与验证规则细则

来源：`cursor-kilo-supertool-mature-stack/references/VERIFICATION-LOGIC.md` + `SKILL.md`（Evidence-First Acceptance）。本文件为主 SKILL.md §执行与验证规则的展开。

## 要避免的错误模式（失败-only 验证）

坏模式：真实执行发生、工具调用成功、流程完成，但验证器只搜索异常字符串 → 每个周期都被标 FAIL。这制造假失败、掩盖真实状态。禁止。

## 双向验证模型

每个周期同时检测成功与失败信号：

| 类型 | 信号 |
|------|------|
| 成功信号 | 真实执行发生；流程/工具被调用；执行产生了输出；输出有效 |
| 失败信号 | 执行无输出；mock/静态响应；流程未触发；工具未调用 |

## 加权评分

```text
execution_real    = +3   # 真实执行发生
tool_invoked      = +2   # 工具/流程被调用
output_generated  = +3   # 由执行产生了输出

mock_detected     = -4   # 发现 mock 或静态响应
missing_execution = -5   # 执行缺失
flow_bypass       = -5   # 流程被绕过
```

判定：`score >= 5 → OK`；`score 1..4 → DEGRADED`；`score <= 0 → FAIL`。

## 每周期必需输出

```json
{
  "execution_verified": true,
  "flow_verified": true,
  "tool_verified": true,
  "output_valid": true,
  "score": 10,
  "status": "OK"
}
```

## 验收规则

- 未知（UNKNOWN）不自动等于 FAIL；任何异常也不自动等于 FAIL。
- 报告文件、脚本输出、打包产物本身不构成验收；验收必须逐条对比 claim 与 evidence。
- 被拒 claim 必须进入 Repair Loop 或保持显式 unresolved。
- 存在未解决拒绝项或阻塞项时，不得声明 PASS。

## 测试验证规则（供 reasonix-test-verify 使用）

- 状态标记：`PASS` / `PARTIAL` / `FAIL` / `PASS_WITH_KNOWN_ISSUES`。
- `PASS_WITH_KNOWN_ISSUES` 仅当失败项能在 known_failures 清单中对应。
- 输出须含：命令、通过/失败/错误/跳过数、耗时、失败项明细（含 is_known_failure）。
- 测试运行不修改源码；不执行需外部服务连接的真实集成测试（除非已授权确认安全）。

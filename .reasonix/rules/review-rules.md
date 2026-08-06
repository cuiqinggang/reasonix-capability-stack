# Review Rules — Reasonix 成熟生态站

> 适配自 `cursor-kilo-supertool-mature-stack/references/rules/review-rules.md`；评分体系与验收规则原样保留，模型路由相关引用改为 Reasonix 原生机制。

## Gate Review 原则

1. 双向验证：同时检测成功信号和失败信号。
2. 未知不是自动 FAIL。
3. 异常不是自动 FAIL。
4. 加权评分，不单因素判定。

## 加权评分

```
execution_real     = +3    （真实执行发生）
routing_correct    = +2    （路由/落位正确）
tool_invoked       = +2    （工具/流程被调用）
output_generated   = +3    （由执行产生了输出）

mock_detected      = -4    （发现 mock 或静态响应）
missing_execution  = -5    （执行缺失）
routing_bypass     = -5    （流程被绕过）

score >= 5  → OK
score 1..4  → DEGRADED
score <= 0  → FAIL
```

## 验收规则

- 最终报告 / 脚本输出 / 文件存在不单独构成最终验收。
- 最终验收必须逐条比对 claims 和 evidence。
- 被拒绝的 claims 必须经过 repair loop 修复或保留为显式 unresolved。
- 有未解决的被拒绝 claims 时不得输出 PASS。
- 不把历史 PASS 冒充为当前验证。

## 代码审查标准

- 功能正确性。
- 边界条件处理。
- 敏感信息泄露检查。
- 向后兼容性。
- 与现有代码约定一致性。

## Reasonix 落位

- 审查执行：`reasonix-review-audit`（只读子智能体，模式 review / audit / review+audit）。
- 关卡验收：`reasonix-gate-controller`（加载 claims → 收集证据 → 双向评分 → 分类 → 出报告）。
- 修复回填：`reasonix-executor-repair`（被拒 claim → 最小修复 → 回归 → ≤3 轮 → 升级）。

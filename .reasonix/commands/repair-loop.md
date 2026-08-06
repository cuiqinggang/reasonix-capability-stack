# Repair Loop 命令

## 命令名

`/repair-loop <失败项列表>` — 对检测到的失败执行最小修复与回归验证。

## 触发时机

- Gate Review 判定 REJECTED 后;
- 验证失败(测试未过、证据缺失、产物错误)时;
- full-verify 检查项 FAIL 后。

## 执行步骤

1. **识别失败项**:接收 Gate Review 的 REJECTED claims 或验证失败清单。
2. **固化验收标准**:读取原任务验收标准(只读,**不修改**)。
3. **逐项修复**(对每个失败项):
   a. 分析根因;
   b. 应用最小修复(重跑验证/补齐证据/修正配置或逻辑,仅改失败相关的最小范围);
   c. 回归验证(重新执行 Gate Review 对该项 claim 的检查);
   d. 修复通过 → 标记 `REPAIRED`;仍失败 → 标记 `BLOCKED` 并记录原因。
4. **重提交**:将被拒 claim 的修复证据与更新后的产物重新提交 Gate Review。
5. **轮次控制**:每项最多 3 轮;第 4 轮仍失败 → 标记 `EXHAUSTED`,停止自动修复。
6. **人工升级**:EXHAUSTED 或 BLOCKED 项交人工决策,不得自行降低验收标准。
7. **输出 repair log**:写入 `.reasonix/reports/repair-log-{timestamp}.json`。

## 输入要求

- 失败项列表(来自 Gate Review 或验证器)。
- 验收标准(只读;禁止以修复为由改写)。
- 现有证据与产物路径。

## 输出/证据要求

- 修复日志:`.reasonix/reports/repair-log-{timestamp}.json`(字段:repair_run、failed_items、repaired、blocked、exhausted、repairs[])。
- 每条修复记录含:item、root_cause、action、regression_result(PASS/FAIL)、rounds。
- 修复后重跑的证据输出写入 `.reasonix/evidence/`。

## 失败处理

- 密钥/凭据相关失败 → 标记 `BLOCKED_EXTERNAL_DEPENDENCY`,不尝试修复。
- 操作系统级配置 → 不自动修改,标记 BLOCKED 并升级。
- 用户未授权的删改 → 拒绝执行。
- 第三方服务不可用 → 标记 BLOCKED,等待恢复后重试。
- 3 轮上限内无法修复 → EXHAUSTED,人工介入后按人工指令继续。

---

适配自 Kilo commands/repair-loop.md(已验证流程,已剥离模型路由与旧路径)
